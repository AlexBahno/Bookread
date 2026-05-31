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
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AccountDeletionError.userNotAuthenticated
        }
        
        let currentUserId = user.uid
        
        do {
            try await removeAllSocialConnections(for: currentUserId)
                        
            try await db.collection("users").document(currentUserId).delete()
            
            try await user.delete()
        } catch let error as NSError {
            if error.domain == AuthErrorDomain && error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                throw AccountDeletionError.requiresRecentLogin
            } else {
                throw AccountDeletionError.firestoreError(error)
            }
        }
    }
    
    func changePassword(to newPassword: String) async throws {
        guard let user = auth.currentUser else {
            throw PasswordChangeError.userNotAuthenticated
        }
        
        do {
            try await user.updatePassword(to: newPassword)
            
        } catch let error as NSError {
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
    
    private func removeAllSocialConnections(for currentUserId: String) async throws {
        let followingSnapshot = try await db.collection("users")
            .document(currentUserId)
            .collection("following")
            .getDocuments()
        
        let followingIds = followingSnapshot.documents.map { $0.documentID }
        guard !followingIds.isEmpty else { return }
        
        let chunkedIds = followingIds.chunked(into: 250)
        
        for chunk in chunkedIds {
            let batch = db.batch()
            
            for targetId in chunk {
                let myFollowingRef = db.collection("users").document(currentUserId).collection("following").document(targetId)
                batch.deleteDocument(myFollowingRef)
                
                let targetFollowerRef = db.collection("users").document(targetId).collection("followers").document(currentUserId)
                batch.deleteDocument(targetFollowerRef)
            }
            
            try await batch.commit()
        }
    }
}
