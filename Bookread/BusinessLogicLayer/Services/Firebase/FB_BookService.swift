//
//  BookService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 27/05/2026.
//

import FirebaseFirestore
import FirebaseAuth

enum BookServiceError: LocalizedError {
    case userNotAuthenticated
    case decodingFailed(Error)
    case firestoreError(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "No authenticated user found."
        case .decodingFailed(let error):
            return "Failed to parse book data: \(error.localizedDescription)"
        case .firestoreError(let error):
            return "Database error: \(error.localizedDescription)"
        }
    }
}

protocol FB_BookServiceProtocol {
    
    func addBook(book: UserBook) async throws
    func getUserBook(bookId: String) async throws -> UserBook?
    func bookStream(bookId: String) -> AsyncThrowingStream<UserBook?, Error>
    func userBooksStream() -> AsyncThrowingStream<[UserBook], Error>
    func updateBook(
        bookID: String,
        updatedData: [String: Any]
    ) async throws
    func fetchUserBooks(userID: String) async throws -> [UserBook]
}

final class FB_BookService: FB_BookServiceProtocol {
    
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    
    func fetchUserBooks(userID: String) async throws -> [UserBook] {
        do {
            let snapshot = try await firestore.collection("users")
                .document(userID)
                .collection("userBooks")
                .getDocuments()
            
            let books = snapshot.documents.compactMap { document -> UserBook? in
                do {
                    return try document.data(as: UserBook.self)
                } catch {
                    print("Помилка парсингу книги \(document.documentID): \(error)")
                    return nil
                }
            }
            
            return books
            
        } catch let error as NSError {
            throw BookServiceError.firestoreError(error)
        }
    }
    
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
