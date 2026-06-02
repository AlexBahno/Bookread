//
//  AuthService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 18/05/2026.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn

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

protocol FB_AuthServiceProtocol {
    
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
    
    func isUsernameTaken(_ username: String) async throws -> Bool
    func changePassword(to newPassword: String) async throws
    func deleteAccount() async throws
}

final class FB_AuthService: FB_AuthServiceProtocol {
    
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    
    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw AccountDeletionError.userNotAuthenticated
        }
        
        let currentUserId = user.uid
        
        do {
            try await removeAllSocialConnections(for: currentUserId)
                        
            try await firestore.collection("users").document(currentUserId).delete()
            
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
        let followingSnapshot = try await firestore
            .collection("users")
            .document(currentUserId)
            .collection("following")
            .getDocuments()
        
        let followingIds = followingSnapshot.documents.map { $0.documentID }
        guard !followingIds.isEmpty else { return }
        
        let chunkedIds = followingIds.chunked(into: 250)
        
        for chunk in chunkedIds {
            let batch = firestore.batch()
            
            for targetId in chunk {
                let myFollowingRef = firestore
                    .collection("users")
                    .document(currentUserId)
                    .collection("following")
                    .document(targetId)
                batch.deleteDocument(myFollowingRef)
                
                let targetFollowerRef = firestore
                    .collection("users")
                    .document(targetId)
                    .collection("followers")
                    .document(currentUserId)
                batch.deleteDocument(targetFollowerRef)
            }
            
            try await batch.commit()
        }
    }
}

// MARK: - Sign Up
extension FB_AuthService {
    
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
        let snapshot = try await firestore
            .collection("users")
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
extension FB_AuthService {
    
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
