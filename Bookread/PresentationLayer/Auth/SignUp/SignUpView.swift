//
//  SignUpView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 07.02.2026.
//

import SwiftUI

struct SignUpView: View {
    
    enum Constant {
        static let usernameFieldId: String = "Username"
        static let emailFieldId: String = "email"
        static let passwordFieldId: String = "password"
        static let confirmPassFieldId: String = "confirmPass"
    }
    
    @ObservedObject private var viewModel: SignUpViewModel
    
    @State private var isScrollDisabled = true
    
    @FocusState var isUsernameFocused: Bool
    @FocusState var isEmailFocused: Bool
    @FocusState var isPasswordFocused: Bool
    @FocusState var isConfirmPasswordFocused: Bool
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16.flexible())
            .background(.backgroundFAFAF8)
            .toolbarVisibility(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(viewModel.isLoading)
            .animation(.easeInOut, value: isUsernameFocused)
            .animation(.easeInOut, value: isEmailFocused)
            .animation(.easeInOut, value: isPasswordFocused)
            .animation(.easeInOut, value: isConfirmPasswordFocused)
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
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: .zero) {
                    header
                        .padding(.top, 32.flexible())
                        .padding(.bottom, 32.flexible())
                    
                    registerForm
                        .padding(.bottom, 16.flexible())
                    
                    AppStyleButton(
                        text: "Create an account",
                        type: .withGreenBackground,
                        isDisabled: !viewModel.isFormValid
                    ) {
                        viewModel.signUpTapped()
                    }
                    .padding(.bottom, 32.flexible())
                    .animation(.default, value: viewModel.isFormValid)
                    
                    complexDivider
                    
                    registerWithGoogleOrApple
                    
                    Spacer()
                }
            }
            .scrollDisabled(isScrollDisabled)
            .onChange(of: isUsernameFocused) {
                isScrollDisabled = !isUsernameFocused
                scrollToSection(Constant.usernameFieldId, isScroll: isUsernameFocused, proxy)
            }
            .onChange(of: isEmailFocused) {
                isScrollDisabled = !isEmailFocused
                scrollToSection(Constant.emailFieldId, isScroll: isEmailFocused, proxy)
            }
            .onChange(of: isPasswordFocused) {
                isScrollDisabled = !isPasswordFocused
                scrollToSection(Constant.passwordFieldId, isScroll: isPasswordFocused, proxy)
            }
            .onChange(of: isConfirmPasswordFocused) {
                isScrollDisabled = !isConfirmPasswordFocused
                scrollToSection(
                    Constant.confirmPassFieldId,
                    isScroll: isConfirmPasswordFocused,
                    proxy
                )
            }
        }
    }
    
    var header: some View {
        VStack(spacing: 8.flexible()) {
            HStack {
                Text("Register")
                    .interRegular(size: 28.flexible())
                    .fontWeight(.bold)
                    .foregroundStyle(.text1A1A1A)
                
                Spacer()
            }
            
            HStack {
                Text("Create an account to get started")
                    .interRegular(size: 18.flexible())
                    .foregroundStyle(Color.gray666666)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
    
    var registerForm: some View {
        VStack(spacing: 8.flexible()) {
            usernameStack
            
            emailStack
            
            passwordStack
            
            confirmPasswordStack
        }
    }
    
    var complexDivider: some View {
        HStack(spacing: 8.flexible()) {
            Rectangle()
                .foregroundStyle(.gray666666)
                .frame(maxWidth: .infinity)
                .frame(height: 0.5.flexible())
            
            Text("Or register with")
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
    
    var registerWithGoogleOrApple: some View {
        HStack(spacing: 16.flexible()) {
            AppStyleButton(
                text: "",
                image: Image(.googleLogo),
                type: .withWhiteBackground
            ) {
                viewModel.signUpWithGoogle()
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
private extension SignUpView {
    var usernameStack: some View {
        VStack(alignment: .leading, spacing: 4.flexible()) {
            BaseTextField(
                text: $viewModel.newUser.username,
                isError: viewModel.isUsernameError,
                keyboardType: .default,
                textContextType: .username,
                isSecureTextEntry: false,
                placeholder: "Username",
                onCommit: {
                    viewModel.checkUsernameError()
                }
            )
            .focused($isUsernameFocused)
            
            if isUsernameFocused || viewModel.isUsernameError {
                Text("Requirments: 3-20 charachters, no spaces")
                    .interRegular(size: 14.flexible())
                    .fontWeight(.light)
                    .foregroundStyle(.gray666666)
                    .multilineTextAlignment(.leading)
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                        .animation(.easeInOut)
                    )
            }
        }
        .id(Constant.usernameFieldId)
    }
    
    var emailStack: some View {
        VStack(alignment: .leading, spacing: 4.flexible()) {
            BaseTextField(
                text: $viewModel.newUser.email,
                isError: viewModel.isEmailError,
                keyboardType: .emailAddress,
                textContextType: .emailAddress,
                isSecureTextEntry: false,
                placeholder: "E-mail",
                onCommit: {
                    viewModel.checkEmailError()
                }
            )
            .focused($isEmailFocused)
            
            if isEmailFocused || viewModel.isEmailError {
                Text("Requirments: just enter correct email, which haven`t been used yet :)")
                    .interRegular(size: 14.flexible())
                    .fontWeight(.light)
                    .foregroundStyle(.gray666666)
                    .multilineTextAlignment(.leading)
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                        .animation(.easeInOut)
                    )
            }
        }
        .id(Constant.emailFieldId)
    }
    
    var passwordStack: some View {
        VStack(alignment: .leading, spacing: 4.flexible()) {
            BaseTextField(
                text: $viewModel.password,
                isError: viewModel.isPasswordError,
                keyboardType: .default,
                textContextType: .password,
                isSecureTextEntry: true,
                placeholder: "Password",
                onCommit: {
                    viewModel.checkPasswordError()
                }
            )
            .focused($isPasswordFocused)
            
            if isPasswordFocused || viewModel.isPasswordError {
                Text("Requirments: ")
                    .interRegular(size: 14.flexible())
                    .fontWeight(.light)
                    .foregroundStyle(.gray666666)
                    .multilineTextAlignment(.leading)
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                        .animation(.easeInOut)
                    )
            }
        }
        .id(Constant.passwordFieldId)
    }
    
    var confirmPasswordStack: some View {
        VStack(alignment: .leading, spacing: 4.flexible()) {
            BaseTextField(
                text: $viewModel.confirmPassword,
                isError: viewModel.isConfirmPasswordError,
                keyboardType: .default,
                textContextType: .password,
                isSecureTextEntry: true,
                placeholder: "Confirm Password",
                onCommit: {
                    viewModel.checkConfirmPasswordError()
                }
            )
            .focused($isConfirmPasswordFocused)
            
            if isConfirmPasswordFocused || viewModel.isConfirmPasswordError {
                Text("Requirments: ")
                    .interRegular(size: 14.flexible())
                    .fontWeight(.light)
                    .foregroundStyle(.gray666666)
                    .multilineTextAlignment(.leading)
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                        .animation(.easeInOut)
                    )
            }
        }
        .id(Constant.confirmPassFieldId)
    }
}

// MARK: - Helpers
private extension SignUpView {
    func scrollToSection(
        _ section: String,
        isScroll: Bool,
        _ proxy: ScrollViewProxy
    ) {
        if isScroll {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    proxy.scrollTo(section, anchor: .bottom)
                }
            }
        }
    }
}
