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
    func getUserBy(id: String) async throws -> AppUser?
    func updateUser(
        with uid: String,
        updatedData: [String: Any]
    ) async -> Bool
    func isUsernameTaken(_ username: String) async throws -> Bool
    func searchUsers(with query: String) async throws -> [AppUser]
    
    // signUp
    func signUp(
        with email: String,
        and password: String,
        as username: String
    ) async throws -> String
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
        for userId: String,
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
    
    func getUserBy(id: String) async throws -> AppUser? {
        let userRef = firestore.collection("users").document(id)
        
        do {
            let userProfile = try await userRef.getDocument(as: AppUser.self)
            return userProfile
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func updateUser(
        with uid: String,
        updatedData: [String: Any]
    ) async -> Bool {
        do {
            try await firestore
                .collection("users")
                .document(uid)
                .updateData(updatedData)
            
            return true
        } catch {
            print("User with id \(uid) wasnt updated")
            return false
        }
    }
    
    func searchUsers(with query: String) async throws -> [AppUser] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        
        let currentUserId = auth.currentUser?.uid
        
        let lowercasedQuery = query.lowercased()
        
        let snapshot = try await firestore.collection("users")
            .whereField("searchableName", isGreaterThanOrEqualTo: lowercasedQuery)
            .whereField("searchableName", isLessThanOrEqualTo: lowercasedQuery + "\u{f8ff}")
            .limit(to: 20)
            .getDocuments()
        
        let users = snapshot.documents.compactMap { document -> AppUser? in
            guard document.documentID != currentUserId else { return nil }
            return try? document.data(as: AppUser.self)
        }
        
        return users
    }
}

// MARK: - Sign Up
extension FirebaseService {
    
    func signUp(
        with email: String,
        and password: String,
        as username: String,
    ) async throws -> String {
        let authResult = try await auth.createUser(
            withEmail: email, password: password
        )
        let userId = authResult.user.uid
        
        try await firestore
            .collection("users")
            .document(userId)
            .updateData(
                [
                    "username": username,
                    "searchableName": username.lowercased()
                ]
            )
        
        return userId
    }
    
    func isUsernameTaken(_ username: String) async throws -> Bool {
        let snapshot = try await firestore.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()
        
        return snapshot.isEmpty
    }
    
    func signUpWithGoogle(
        presentingVC: UIViewController,
        newUserCase: @escaping (String) -> Void,
        existedUserCase: @escaping () -> Void
    ) async {
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw NSError(
                    domain: "Auth",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing Firebase Client ID"]
                )
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            let googleResult = try await GIDSignIn.sharedInstance
                .signIn(withPresenting: presentingVC)
            
            guard let idToken = googleResult.user.idToken?.tokenString else {
                throw NSError(
                    domain: "Auth",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to fetch Google ID Token"]
                )
            }
            let accessToken = googleResult.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )
            
            let authResult = try await auth.signIn(with: credential)
            
            let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
            let uid = authResult.user.uid
            
            await MainActor.run {
                if isNewUser {
                    newUserCase(uid)
                } else {
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
        let _ = try await auth.signIn(
            withEmail: email,
            password: password
        )
        
        onSuccess()
    }
    
    func signInWithGoogle(
        presentingVC: UIViewController,
        onSuccess: @escaping () -> Void
    ) async {
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            
            let googleResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
            
            guard let idToken = googleResult.user.idToken?.tokenString else { return }
            let accessToken = googleResult.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
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
        guard let uid = auth.currentUser?.uid else {
            throw NetworkError.unknown
        }
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
        
        let document = try await docRef.getDocument()
        
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
            
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    continuation.yield([])
                    return
                }
                
                let books = documents.compactMap { try? $0.data(as: UserBook.self) }
                
                continuation.yield(books)
            }
            
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
            
            let listener = docRef.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                let liveBook = try? snapshot?.data(as: UserBook.self)
                
                continuation.yield(liveBook)
            }
            
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
        
        let batch = firestore.batch()
        
        let sessionRef = firestore
            .collection("users")
            .document(uid)
            .collection("readingSessions")
            .document()
        
        let bookRef = firestore
            .collection("users")
            .document(uid)
            .collection("userBooks")
            .document(session.bookId)
        
        try batch.setData(from: session, forDocument: sessionRef)
        
        let newStatus: ReadingStatus = isFinished ? .finished : .reading
        let bookUpdates: [String: Any] = [
            "progress": newTotalProgress,
            "status": newStatus.rawValue,
            "lastReadAt": FieldValue.serverTimestamp(),
            "totalReadingSeconds": FieldValue.increment(Int64(session.durationInSeconds))
        ]
        batch.updateData(bookUpdates, forDocument: bookRef)
        
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
        for userId: String,
        limit: Int = 20
    ) -> AsyncThrowingStream<[ReadingSession], Error> {
        AsyncThrowingStream { continuation in
            let query = firestore
                .collection("users")
                .document(userId)
                .collection("readingSessions")
                .order(by: "startTime", descending: true)
                .limit(to: limit)
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
                print("🛑 Firebase Recent Activity Listener safely removed for user: \(userId).")
            }
        }
    }
}
