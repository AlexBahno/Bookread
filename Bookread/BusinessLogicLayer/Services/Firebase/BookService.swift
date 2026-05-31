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

protocol BookServiceProtocol {
    func fetchUserBooks(userID: String) async throws -> [UserBook]
}

final class BookService: BookServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func fetchUserBooks(userID: String) async throws -> [UserBook] {
        do {
            let snapshot = try await db.collection("users")
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
}
