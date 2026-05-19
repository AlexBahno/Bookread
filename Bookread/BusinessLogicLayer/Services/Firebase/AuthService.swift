//
//  AuthService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 18/05/2026.
//

import FirebaseAuth
import FirebaseFirestore

enum AccountDeletionError: LocalizedError {
    case userNotAuthenticated
    case requiresRecentLogin
    case firestoreError(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "No authenticated user found."
        case .requiresRecentLogin:
            return "For security reasons, you must log in again before deleting your account."
        case .firestoreError(let error):
            return "Failed to delete user data: \(error.localizedDescription)"
        }
    }
}

protocol AuthServiceProtocol {
    
    func deleteAccount() async throws
}

final class AuthService: AuthServiceProtocol {
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AccountDeletionError.userNotAuthenticated
        }
        
        let db = Firestore.firestore()
        let uid = user.uid
        
        do {
            // 2. Delete the user's profile document from Firestore
            try await db.collection("users").document(uid).delete()
            
            // 3. Delete the user from Firebase Authentication
            try await user.delete()
            
        } catch let error as NSError {
            // 4. Handle the specific "Recent Login Required" security error
            if error.domain == AuthErrorDomain &&
                error.code == AuthErrorCode.requiresRecentLogin.rawValue
            {
                throw AccountDeletionError.requiresRecentLogin
            } else {
                throw AccountDeletionError.firestoreError(error)
            }
        }
    }
}
