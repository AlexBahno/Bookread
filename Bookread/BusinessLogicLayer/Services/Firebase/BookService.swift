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
    func fetchUserBooks() async throws -> [UserBook]
}

final class BookService: BookServiceProtocol {
    
    private let db = Firestore.firestore()
    
    /// Завантажує всі книги поточного користувача з підколекції userBooks
    /// - Returns: Масив об'єктів UserBook
    func fetchUserBooks() async throws -> [UserBook] {
        // 1. Перевіряємо, чи користувач авторизований
        guard let userId = Auth.auth().currentUser?.uid else {
            throw BookServiceError.userNotAuthenticated
        }
        
        do {
            // 2. Формуємо запит до підколекції userBooks
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("userBooks")
                .getDocuments()
            
            // 3. Автоматичний мапінг документів у структури Swift
            // compactMap відкине документи, які не вдалося розпарсити (наприклад, якщо структура в базі змінилася)
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
            // Перехоплюємо помилки Firestore (наприклад, відсутність інтернету та кешу)
            throw BookServiceError.firestoreError(error)
        }
    }
}
