//
//  SignInViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 11.03.2026.
//

import Combine
import Foundation
import FirebaseAuth
import UIKit
import FirebaseCore
import GoogleSignIn

struct SignInRouter {
    let onSignUpSuccess: () -> Void
}

final class SignInViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    @Published private(set) var isLoading = false
    
    @Published var isUnsuccessfulTry = false
    
    private let authService: FB_AuthServiceProtocol
    private let router: SignInRouter
    
    var isFormValid: Bool {
        true
    }
    
    init(
        authService: FB_AuthServiceProtocol,
        router: SignInRouter
    ) {
        self.authService = authService
        self.router = router
    }
    
    // MARK: - Email & Password Sign In
    func signInWithEmail() {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanEmail.isEmpty, !password.isEmpty else {
            return
        }
        
        isLoading = true
        Task {
            do {
                try await authService.signIn(
                    with: cleanEmail,
                    and: password,
                    onSuccess: self.router.onSignUpSuccess
                )
            } catch {
                self.isUnsuccessfulTry = true
                print(error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() {
        guard let presentingVC = UIApplication.shared.getTopViewController() else {
            return
        }
        
        isLoading = true
        
        Task {
            await authService.signInWithGoogle(
                presentingVC: presentingVC,
                onSuccess: self.router.onSignUpSuccess
            )
            
            isLoading = false
        }
    }
}
