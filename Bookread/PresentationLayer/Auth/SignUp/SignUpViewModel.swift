//
//  SignUpViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 07.02.2026.
//

import Combine
import Foundation
import FirebaseAuth
import Firebase
import GoogleSignIn
import FirebaseCore

struct SignUpRouter {
    let onSignUpSuccess: () -> Void
    let onNeedsUsername: (String) -> Void
}

final class SignUpViewModel: ObservableObject {
    
    @Published var newUser = User()
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published private(set) var isUsernameError = false
    @Published private(set) var isEmailError = false
    @Published private(set) var isPasswordError = false
    @Published private(set) var isConfirmPasswordError = false
    
    @Published private(set) var isLoading: Bool = false
    
    private let firebaseService: FirebaseServiceProtocol
    private let router: SignUpRouter
    
    var isFormValid: Bool {
        isValidUsername() && isValidEmail() && isValidPassword()
    }
    
    init(
        firebaseService: FirebaseServiceProtocol,
        router: SignUpRouter
    ) {
        self.firebaseService = firebaseService
        self.router = router
    }
}

// MARK: - isValid functions
private extension SignUpViewModel {
    
    func isValidUsername() -> Bool {
        let pattern = #"^[A-Z0-9a-z._-]{3,20}$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(newUser.username.startIndex..., in: newUser.username)
        return regex?.firstMatch(in: newUser.username, options: [], range: range) != nil
    }
    
    func isValidEmail() -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(newUser.email.startIndex..., in: newUser.email)
        return regex?.firstMatch(in: newUser.email, options: [], range: range) != nil
    }
    
    func isValidPassword() -> Bool {
        let pattern = #"^[A-Z0-9a-z._+-=]{6,}$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(password.startIndex..., in: password)
        return regex?.firstMatch(in: password, options: [], range: range) != nil &&
        password == confirmPassword
    }
}

// MARK: - Check states of fields
extension SignUpViewModel {
    
    func checkUsernameError() {
        self.isUsernameError = !self.isValidUsername()
    }
    
    func checkEmailError() {
        self.isEmailError = !self.isValidEmail()
    }
    
    func checkPasswordError() {
        self.isPasswordError = !self.isValidPassword()
    }
    
    func checkConfirmPasswordError() {
        self.isConfirmPasswordError = self.confirmPassword.isEmpty ||
        self.confirmPassword != self.password
    }
}

// MARK: - Sign up process
extension SignUpViewModel {
    
    func signUpTapped() {
        isLoading = true
        
        Task {
            do {
                try await self.registerUser()
            } catch let error as NSError {
                isLoading = false
                
                if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                    switch authErrorCode {
                    case .emailAlreadyInUse:
                        self.isEmailError = true
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func registerUser() async throws {
        // 1. Check if the username is taken BEFORE making the account
        let available = try await isUsernameTaken()
        guard available else {
            self.isLoading = false
            self.isUsernameError = true
            return
        }
        
        // 2. Create the account
        // If the email is taken, Firebase will automatically throw an error here
        // and instantly stop the rest of the function from running.
        let authResult = try await Auth.auth().createUser(
            withEmail: newUser.email, password: password
        )
        let userId = authResult.user.uid
        
        // 3. Save the custom username to Firestore
        try await firebaseService.getFirestore()
            .collection("users")
            .document(userId)
            .updateData(
                ["username": newUser.username]
            )
        
        isLoading = false
        
        router.onSignUpSuccess()
    }
    
    private func isUsernameTaken() async throws -> Bool {
        // Query the 'users' collection to see if this username already exists
        let snapshot = try await firebaseService.getFirestore().collection("users")
            .whereField("username", isEqualTo: newUser.username)
            .getDocuments()
        
        // If the snapshot is completely empty, the username is safe to use!
        return snapshot.isEmpty
    }
}

// MARK: - Sign up with Google account
extension SignUpViewModel {
    
    func signUpWithGoogle() {
        // 1. Grab the current View Controller using our helper!
        guard let presentingVC = UIApplication.shared.getTopViewController() else {
            print("Could not find presentation context.")
            return
        }
        
        self.isLoading = true
        
        Task {
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
                let authResult = try await Auth.auth().signIn(with: credential)
                
                // 6. Check if this is their very first time logging in
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                let uid = authResult.user.uid
                
                // 7. Route back on the Main Thread to update the UI/Coordinator
                await MainActor.run {
                    if isNewUser {
                        // Brand new user! Send them to pick a username
                        self.router.onNeedsUsername(uid)
                    } else {
                        // Returning user! Send them to the main app
                        self.router.onSignUpSuccess()
                    }
                }
            } catch {
                print("Error")
            }
            
            isLoading = false
        }
    }
}
