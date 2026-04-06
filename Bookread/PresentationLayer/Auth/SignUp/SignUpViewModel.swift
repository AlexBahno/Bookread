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

@MainActor
final class SignUpViewModel: ObservableObject {
    
    @Published var newUser = AppUser()
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
    
    @MainActor
    private func registerUser() async throws {
        // Check if the username is taken BEFORE making the account
        let available = try await firebaseService.isUsernameTaken(newUser.username)
        guard available else {
            self.isLoading = false
            self.isUsernameError = true
            return
        }
        
        let userId = try await firebaseService.signUp(
            with: newUser.email,
            and: password,
            as: newUser.username
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            
            self.router.onSignUpSuccess()
        }
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
            await firebaseService.signUpWithGoogle(
                presentingVC: presentingVC,
                newUserCase: router.onNeedsUsername,
                existedUserCase: router.onSignUpSuccess
            )
            
            self.isLoading = false
        }
    }
}
