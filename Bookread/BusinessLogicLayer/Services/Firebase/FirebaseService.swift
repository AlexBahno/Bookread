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

protocol FirebaseServiceProtocol {
    
    func getCurrentUser() -> User?
    func updateUser(
        with uid: String,
        updatedData: [String: Any]
    ) async throws
    
    func signUp(with email: String, and password: String, as username: String) async throws
    func isUsernameTaken(_ username: String) async throws -> Bool
    func signUpWithGoogle(
        presentingVC: UIViewController,
        newUserCase: @escaping (String) -> Void,
        existedUserCase: @escaping () -> Void
    ) async
    
    func signIn(
        with email: String,
        and password: String,
        onSuccess: @escaping () -> Void
    ) async throws
    func signInWithGoogle(
        presentingVC: UIViewController,
        onSuccess: @escaping () -> Void
    ) async
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
            .updateData(
                ["username": username]
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
