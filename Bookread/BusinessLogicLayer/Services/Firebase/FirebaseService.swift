//
//  FirebaseService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 22.02.2026.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

protocol FirebaseServiceProtocol {
    
    // user
    func getCurrentUser() -> User?
    func updateUser(
        with uid: String,
        updatedData: [String: Any]
    ) async throws
    func isUsernameTaken(_ username: String) async throws -> Bool
    
    // signUp
    func signUp(
        with email: String,
        and password: String,
        as username: String
    ) async throws
    func signUpWithGoogle(
        presentingVC: UIViewController,
        newUserCase: @escaping (String) -> Void,
        existedUserCase: @escaping () -> Void
    ) async
    
    // signIn
    func signIn(
        with email: String,
        and password: String,
        onSuccess: @escaping () -> Void
    ) async throws
    func signInWithGoogle(
        presentingVC: UIViewController,
        onSuccess: @escaping () -> Void
    ) async
    
    // book
    func addBook(book: UserBook) async throws
    func getUserBook(bookId: String) async throws -> UserBook?
    func bookStream(bookId: String) -> AsyncThrowingStream<UserBook?, Error>
    func userBooksStream() -> AsyncThrowingStream<[UserBook], Error>
    func updateBook(
        bookID: String,
        updatedData: [String: Any]
    ) async throws
    
    // reading session
    func logReadingSession(
        session: ReadingSession,
        newTotalProgress: Int,
        isFinished: Bool
    ) async throws
    func bookSessionsStream(
        for bookId: String
    ) -> AsyncThrowingStream<[ReadingSession], Error>
    func recentActivityStream(
        limit: Int
    ) -> AsyncThrowingStream<[ReadingSession], Error>
}

final class FirebaseService: FirebaseServiceProtocol {
    
    let auth = Auth.auth()
    let storage = Storage.storage()
    let firestore = Firestore.firestore()
    
    func getCurrentUser() -> User? {
        auth.currentUser
    }
    
    func updateUser(
        with uid: String,
        updatedData: [String: Any]
    ) async throws {
        try await firestore
            .collection("users")
            .document(uid)
            .updateData(updatedData)
    }
}

// MARK: - Sign Up
extension FirebaseService {
    
    func signUp(
        with email: String,
        and password: String,
        as username: String
    ) async throws {
        let authResult = try await auth.createUser(
            withEmail: email, password: password
        )
        let userId = authResult.user.uid
        
        // 3. Save the custom username to Firestore
        try await firestore
            .collection("users")
            .document(userId)
            .setData(
                ["username": username],
                merge: true
            )
    }
    
    func isUsernameTaken(_ username: String) async throws -> Bool {
        // Query the 'users' collection to see if this username already exists
        let snapshot = try await firestore.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()
        
        // If the snapshot is completely empty, the username is safe to use!
        return snapshot.isEmpty
    }
    
    func signUpWithGoogle(
        presentingVC: UIViewController,
        newUserCase: @escaping (String) -> Void,
        existedUserCase: @escaping () -> Void
    ) async {
        do {
            // 1. Configure Google Sign-In using your Firebase plist
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw NSError(
                    domain: "Auth",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing Firebase Client ID"]
                )
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            // 2. Trigger the Google Modal (This suspends until the user finishes logging in)
            let googleResult = try await GIDSignIn.sharedInstance
                .signIn(withPresenting: presentingVC)
            
            // 3. Extract the security tokens provided by Google
            guard let idToken = googleResult.user.idToken?.tokenString else {
                throw NSError(
                    domain: "Auth",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to fetch Google ID Token"]
                )
            }
            let accessToken = googleResult.user.accessToken.tokenString
            
            // 4. Convert those tokens into a standard Firebase Auth credential
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )
            
            // 5. Sign in to Firebase!
            let authResult = try await auth.signIn(with: credential)
            
            // 6. Check if this is their very first time logging in
            let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
            let uid = authResult.user.uid
            
            // 7. Route back on the Main Thread to update the UI/Coordinator
            await MainActor.run {
                if isNewUser {
                    // Brand new user! Send them to pick a username
                    newUserCase(uid)
                } else {
                    // Returning user! Send them to the main app
                    existedUserCase()
                }
            }
        } catch {
            print("Error")
        }
    }
}

// MARK: - Sign In
extension FirebaseService {
    
    func signIn(
        with email: String,
        and password: String,
        onSuccess: @escaping () -> Void
    ) async throws {
        // 2. Authenticate with Firebase
        let _ = try await auth.signIn(
            withEmail: email,
            password: password
        )
        
        // 3. Success! Route to the main app
        onSuccess()
    }
    
    func signInWithGoogle(
        presentingVC: UIViewController,
        onSuccess: @escaping () -> Void
    ) async {
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            
            // 2. Trigger the Google Modal
            let googleResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
            
            guard let idToken = googleResult.user.idToken?.tokenString else { return }
            let accessToken = googleResult.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // 3. Authenticate with Firebase
            try await auth.signIn(with: credential)
            
            onSuccess()
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Book
extension FirebaseService {
    
    func addBook(book: UserBook) async throws {
        // Ensure we have a logged-in user
        guard let uid = auth.currentUser?.uid else {
            throw NetworkError.unknown
        }
        // Set the path: users/{uid}/userBooks/{googleBookId}
        let documentReference = firestore
            .collection("users")
            .document(uid)
            .collection("userBooks")
            .document(book.id)
        
        try documentReference.setData(from: book)
        
        print("✅ Successfully saved '\(book.title)' to library!")
    }
    
    func getUserBook(bookId: String) async throws -> UserBook? {
        guard let uid = auth.currentUser?.uid else {
            throw NetworkError.unknown
        }
        
        let docRef = firestore
            .collection("users")
            .document(uid)
            .collection("userBooks")
            .document(bookId)
        
        // Fetch the single document
        let document = try await docRef.getDocument()
        
        // If it exists, decode it into our Swift struct. Otherwise, return nil.
        if document.exists {
            return try document.data(as: UserBook.self)
        } else {
            return nil
        }
    }
    
    func updateBook(bookID: String, updatedData: [String: Any]) async throws {
        guard let uid = auth.currentUser?.uid else {
            throw NetworkError.unknown
        }
        
        try await firestore
            .collection("users")
            .document(uid)
            .collection("userBooks")
            .document(bookID)
            .updateData(updatedData)
    }
    
    func userBooksStream() -> AsyncThrowingStream<[UserBook], Error> {
        AsyncThrowingStream { continuation in
            guard let uid = auth.currentUser?.uid else {
                continuation.finish(throwing: NetworkError.unknown)
                return
            }
            
            let query = firestore
                .collection("users")
                .document(uid)
                .collection("userBooks")
                .order(by: "lastReadAt", descending: true)
            
            // 2. Start the Firebase listener
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    // If Firebase throws an error, crash the stream
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    continuation.yield([]) // Yield an empty array
                    return
                }
                
                let books = documents.compactMap { try? $0.data(as: UserBook.self) }
                
                // 3. Yield the new array into the stream every time the database changes!
                continuation.yield(books)
            }
            
            // 4. THE MAGIC: Clean up the Firebase listener if the stream is cancelled
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    func bookStream(bookId: String) -> AsyncThrowingStream<UserBook?, Error> {
        AsyncThrowingStream { continuation in
            guard let uid = auth.currentUser?.uid else {
                continuation.finish(throwing: NetworkError.unknown)
                return
            }
            
            let docRef = firestore
                .collection("users")
                .document(uid)
                .collection("userBooks")
                .document(bookId)
            
            // 2. Start the Firebase listener
            let listener = docRef.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                // Decode the single document (will be nil if the document was deleted)
                let liveBook = try? snapshot?.data(as: UserBook.self)
                
                // Yield the updated book!
                continuation.yield(liveBook)
            }
            
            // 4. THE MAGIC: Clean up the Firebase listener if the stream is cancelled
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}

// MARK: Reading Sessions
extension FirebaseService {
    
    func logReadingSession(
        session: ReadingSession,
        newTotalProgress: Int,
        isFinished: Bool
    ) async throws {
        guard let uid = auth.currentUser?.uid else {
            throw NetworkError.unknown
        }
        
        // 1. Initialize the Batch
        let batch = firestore.batch()
        
        // 2. Prepare the new Session Document (Auto-generates a random ID)
        let sessionRef = firestore
            .collection("users")
            .document(uid)
            .collection("readingSessions")
            .document()
        
        // 3. Prepare the existing Book Document
        let bookRef = firestore
            .collection("users")
            .document(uid)
            .collection("userBooks")
            .document(session.bookId)
        
        // 4. Attach Operation 1: Save the session
        try batch.setData(from: session, forDocument: sessionRef)
        
        // 5. Attach Operation 2: Update the book
        let newStatus: ReadingStatus = isFinished ? .finished : .reading
        let bookUpdates: [String: Any] = [
            "progress": newTotalProgress,
            "status": newStatus.rawValue,
            "lastReadAt": FieldValue.serverTimestamp(),
            "totalReadingSeconds": FieldValue.increment(Int64(session.durationInSeconds))
        ]
        batch.updateData(bookUpdates, forDocument: bookRef)
        
        // 6. Commit the batch! (Either both succeed, or both fail)
        try await batch.commit()
        
        print("✅ Session safely logged and book progress updated atomically.")
    }
    
    func bookSessionsStream(
        for bookId: String
    ) -> AsyncThrowingStream<[ReadingSession], Error> {
        AsyncThrowingStream { continuation in
            guard let uid = auth.currentUser?.uid else {
                continuation.finish(throwing: NetworkError.unknown)
                return
            }
            
            let query = firestore
                .collection("users")
                .document(uid)
                .collection("readingSessions")
                .whereField("bookId", isEqualTo: bookId)
                .order(by: "startTime", descending: true)
            
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    continuation.yield([])
                    return
                }
                
                let sessions = documents.compactMap { try? $0.data(as: ReadingSession.self) }
                continuation.yield(sessions)
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
                print("🛑 Firebase Book-Specific Session Listener safely removed.")
            }
        }
    }
    
    func recentActivityStream(
        limit: Int = 20
    ) -> AsyncThrowingStream<[ReadingSession], Error> {
        AsyncThrowingStream { continuation in
            guard let uid = auth.currentUser?.uid else {
                continuation.finish(throwing: NetworkError.unknown)
                return
            }
            
            let query = firestore
                .collection("users")
                .document(uid)
                .collection("readingSessions")
                .order(by: "startTime", descending: true)
                .limit(to: limit) // THE MAGIC FILTER
            
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    continuation.yield([])
                    return
                }
                
                let sessions = documents.compactMap { try? $0.data(as: ReadingSession.self) }
                continuation.yield(sessions)
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
                print("🛑 Firebase Recent Activity Listener safely removed.")
            }
        }
    }
    
}
