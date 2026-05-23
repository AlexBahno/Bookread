//
//  BaseTextField.swift
//  Bookread
//
//  Created by Alexandr Bahno on 07.02.2026.
//

import SwiftUI

struct BaseTextField: View {
    
    @FocusState private var isFocused: Bool
    
    @Binding var text: String
    var isError: Bool = false
    let keyboardType: UIKeyboardType
    var autocapitalization: TextInputAutocapitalization = .never
    let textContextType: UITextContentType
    let isSecureTextEntry: Bool
    let placeholder: String
    var onCommit: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if isSecureTextEntry {
                secureField
            } else {
                textField
            }
        }
        .focused($isFocused)
        .padding(.horizontal, 20)
        .frame(height: 50)
        .frame(maxWidth: UIScreen.screenWidth)
        .background {
            RoundedRectangle(cornerRadius: 16.flexible())
                .fill(.secondaryE8DFD0.opacity(0.4))
                .overlay {
                    RoundedRectangle(cornerRadius: 16.flexible())
                        .strokeBorder(
                            isError ? .red : .gray666666,
                            lineWidth: 1.flexible()
                        )
                }
        }
    }
    
    @State private var isPasswordVisible: Bool = false
    
    var secureField: some View {
        ZStack(alignment: .trailing) {
            Group {
                SecureField(placeholder, text: $text)
                    .interRegular(size: 20.flexible())
                    .fontWeight(.medium)
                    .foregroundStyle(.text1A1A1A)
                    .textInputAutocapitalization(autocapitalization)
                    .textContentType(.password)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit {
                        onCommit?()
                    }
                    .opacity(isPasswordVisible ? 0 : 1)
                
                textField
                    .opacity(isPasswordVisible ? 1 : 0)
            }
            .padding(.trailing, 24.flexible())
            .animation(.easeInOut, value: self.isPasswordVisible)
            
            Button(action: {
                performToggle()
            }, label: {
                Image(systemName: self.isPasswordVisible ? "eye.slash" : "eye")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.flexible(), height: 20.flexible())
                    .accentColor(.gray)
            })
        }
    }
    
    var textField: some View {
        TextField(placeholder, text: $text)
            .interRegular(size: 20.flexible())
            .fontWeight(.medium)
            .foregroundStyle(.text1A1A1A)
            .autocorrectionDisabled()
            .textContentType(textContextType)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(autocapitalization)
            .submitLabel(.done)
            .onSubmit {
                onCommit?()
            }
    }
    
    private func performToggle() {
        isPasswordVisible.toggle()
    }
}
