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

enum PasswordChangeError: LocalizedError {
    case userNotAuthenticated
    case requiresRecentLogin
    case weakPassword
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "No authenticated user found."
        case .requiresRecentLogin:
            return "For security reasons, you must log out and log back in before changing your password."
        case .weakPassword:
            return "The new password is too weak. Please use a stronger password (minimum 6 characters)."
        case .unknownError(let error):
            return "Failed to update password: \(error.localizedDescription)"
        }
    }
}

protocol AuthServiceProtocol {
    
    func changePassword(to newPassword: String) async throws
    func deleteAccount() async throws
}

final class AuthService: AuthServiceProtocol {
    
    private let auth = Auth.auth()
    
    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
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
    
    func changePassword(to newPassword: String) async throws {
        // 1. Verify we have an active user
        guard let user = auth.currentUser else {
            throw PasswordChangeError.userNotAuthenticated
        }
        
        do {
            // 2. Attempt to update the password
            try await user.updatePassword(to: newPassword)
            
        } catch let error as NSError {
            // 3. Map Firebase-specific errors to our custom domain errors
            if error.domain == AuthErrorDomain {
                switch AuthErrorCode(rawValue: error.code) {
                case .requiresRecentLogin:
                    throw PasswordChangeError.requiresRecentLogin
                case .weakPassword:
                    throw PasswordChangeError.weakPassword
                default:
                    throw PasswordChangeError.unknownError(error)
                }
            } else {
                throw PasswordChangeError.unknownError(error)
            }
        }
    }
}
