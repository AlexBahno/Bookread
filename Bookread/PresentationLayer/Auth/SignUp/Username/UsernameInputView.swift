//
//  UsernameInputView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 08.03.2026.
//

import SwiftUI

struct UsernameInputView: View {
    
    @ObservedObject private var viewModel: UsernameInputViewModel
    @FocusState var isUsernameFocused: Bool
    
    init(viewModel: UsernameInputViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16.flexible())
            .background(.backgroundFAFAF8)
            .toolbarVisibility(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
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
        VStack(spacing: .zero) {
            header
                .padding(.top, 32.flexible())
                .padding(.bottom, 32.flexible())
            
            usernameStack
                .padding(.bottom, 24.flexible())
            
            AppStyleButton(
                text: "Create an account",
                type: .withGreenBackground,
                isDisabled: viewModel.isUsernameError
            ) {
                viewModel.saveUsername()
            }
            .padding(.bottom, 32.flexible())
            .animation(.default, value: viewModel.isUsernameError)
            
            Spacer()
        }
    }
    
    var header: some View {
        VStack(spacing: 8.flexible()) {
            HStack {
                Text("Complete account")
                    .interRegular(size: 28.flexible())
                    .fontWeight(.bold)
                    .foregroundStyle(.text1A1A1A)
                
                Spacer()
            }
            
            HStack {
                Text("Make up a username for yourself")
                    .interRegular(size: 18.flexible())
                    .foregroundStyle(Color.gray666666)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
    
    var usernameStack: some View {
        VStack(alignment: .leading, spacing: 4.flexible()) {
            BaseTextField(
                text: $viewModel.username,
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
            
            Text(viewModel.underFieldMessage)
                .interRegular(size: 14.flexible())
                .fontWeight(.light)
                .foregroundStyle(viewModel.isUsernameError ? .red : .gray666666)
                .multilineTextAlignment(.leading)
                .transition(
                    .move(edge: .top)
                    .combined(with: .opacity)
                    .animation(.easeInOut)
                )
        }
    }
}
