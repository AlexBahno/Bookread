//
//  SignInView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 11.03.2026.
//

import SwiftUI

struct SignInView: View {
    
    @ObservedObject var viewModel: SignInViewModel
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16.flexible())
            .background(.backgroundFAFAF8)
            .toolbarVisibility(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black
                            .opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: .zero) {
                header
                    .padding(.top, 32.flexible())
                    .padding(.bottom, 32.flexible())
                
                loginForm
                    .padding(.bottom, 16.flexible())
                
                AppStyleButton(
                    text: "Login",
                    type: .withGreenBackground,
                    isDisabled: !viewModel.isFormValid
                ) {
                    viewModel.signInWithEmail()
                }
                .padding(.bottom, 32.flexible())
                .animation(.default, value: viewModel.isFormValid)
                
                complexDivider
                
                loginWithGoogleOrApple
                
//                Spacer()
            }
        }
        .scrollDisabled(true)
    }
    
    var header: some View {
        VStack(spacing: 8.flexible()) {
            HStack {
                Text("Login")
                    .interRegular(size: 28.flexible())
                    .fontWeight(.bold)
                    .foregroundStyle(.text1A1A1A)
                
                Spacer()
            }
            
            HStack {
                Text("Login in your account")
                    .interRegular(size: 18.flexible())
                    .foregroundStyle(Color.gray666666)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
    
    var loginForm: some View {
        VStack(spacing: 8.flexible()) {
            emailStack
            passwordStack
        }
        .animation(.easeInOut, value: viewModel.isUnsuccessfulTry)
    }
    
    var complexDivider: some View {
        HStack(spacing: 8.flexible()) {
            Rectangle()
                .foregroundStyle(.gray666666)
                .frame(maxWidth: .infinity)
                .frame(height: 0.5.flexible())
            
            Text("Or Login with")
                .interRegular(size: 16.flexible())
                .fontWeight(.light)
                .foregroundStyle(.gray666666)
            
            Rectangle()
                .foregroundStyle(.gray666666)
                .frame(maxWidth: .infinity)
                .frame(height: 0.5.flexible())
        }
        .padding(.bottom, 16.flexible())
    }
    
    var loginWithGoogleOrApple: some View {
        HStack(spacing: 16.flexible()) {
            AppStyleButton(
                text: "",
                image: Image(.googleLogo),
                type: .withWhiteBackground
            ) {
                viewModel.signInWithGoogle()
            }
            
            //            AppStyleButton(
            //                text: "",
            //                image: Image(.appleLogo),
            //                type: .withWhiteBackground
            //            ) {
            //
            //            }
        }
    }
}

// MARK: TextFields
private extension SignInView {
    
    var emailStack: some View {
        VStack(alignment: .leading, spacing: 4.flexible()) {
            BaseTextField(
                text: $viewModel.email,
                isError: viewModel.isUnsuccessfulTry,
                keyboardType: .emailAddress,
                textContextType: .emailAddress,
                isSecureTextEntry: false,
                placeholder: "E-mail",
                onCommit: {
                    self.viewModel.isUnsuccessfulTry = false
                }
            )
        }
    }
    
    var passwordStack: some View {
        VStack(alignment: .leading, spacing: 4.flexible()) {
            BaseTextField(
                text: $viewModel.password,
                isError: viewModel.isUnsuccessfulTry,
                keyboardType: .default,
                textContextType: .password,
                isSecureTextEntry: true,
                placeholder: "Password",
                onCommit: {
                    self.viewModel.isUnsuccessfulTry = false
                }
            )
        }
    }
}
