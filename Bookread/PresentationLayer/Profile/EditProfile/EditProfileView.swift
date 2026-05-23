//
//  EditProfileView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 19/05/2026.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    enum Constant {
        static let passwordFieldId: String = "password"
    }
    
    @ObservedObject var viewModel: EditProfileViewModel
    @State private var showingImagePicker = false
    
    @FocusState var isPasswordFocused: Bool
    @State private var isScrollDisabled = true
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundFAFAF8)
            .navigationTitle("Edit profile")
            .onAppear {
                TabBarManager.shared.hide()
            }
            .onDisappear {
                TabBarManager.shared.show()
            }
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $viewModel.selectedPhoto,
                matching: .images
            )
            .animation(.easeInOut, value: isPasswordFocused)
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
            ScrollView {
                VStack(spacing: 16.flexible()) {
                    profileSection
                    
                    BaseTextField(
                        text: $viewModel.username,
                        keyboardType: .default,
                        textContextType: .username,
                        isSecureTextEntry: false,
                        placeholder: "Username"
                    )
                    
                    passwordStack
                    
                    AppStyleButton(
                        text: "Change Password",
                        type: .withGreenBackground,
                        isDisabled: viewModel.isButtonDisabled
                    ) {
                        isPasswordFocused = false
                        Task {
                            await viewModel.changePassword()
                        }
                    }
                    .onChange(of: viewModel.password) { _, _ in
                        if !viewModel.isLoading {
                            withAnimation {
                                viewModel.isButtonDisabled = !viewModel.isValidPassword()
                            }
                            if isPasswordFocused {
                                withAnimation {
                                    viewModel.isPasswordError = false
                                }
                            }
                        }
                    }
                    .onChange(of: isPasswordFocused) { _, _ in
                        if !isPasswordFocused {
                            withAnimation {
                                viewModel.checkPasswordError()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16.flexible())
            }
            .scrollDisabled(isScrollDisabled)
            .onChange(of: isPasswordFocused) {
                isScrollDisabled = !isPasswordFocused
                scrollToSection(Constant.passwordFieldId, isScroll: isPasswordFocused, proxy)
            }
        }
    }
}

// MARK: - Image Section
private extension EditProfileView {
    
    var profileSection: some View {
        HStack(spacing: 16.flexible()) {
            // Profile Image with Camera Button
            ZStack(alignment: .bottomTrailing) {
                if let image = viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80.flexible(), height: 80.flexible())
                        .clipShape(Circle())
                }
                else if let imgURL = viewModel.user?.imagePath {
                    AsyncImage(url: imgURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(.gray9E9E9E.opacity(0.65))
                            .shimmer()
                    }
                    .frame(width: 80.flexible(), height: 80.flexible())
                } else {
                    Circle()
                        .fill(.secondaryE8DFD0)
                        .frame(width: 80.flexible(), height: 80.flexible())
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40.flexible()))
                                .foregroundColor(.primary2D5F5D)
                        )
                }
                
                // Camera Button
                Button(action: { showingImagePicker = true }) {
                    Circle()
                        .fill(.accentC17767)
                        .frame(width: 28.flexible(), height: 28.flexible())
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12.flexible()))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 2.flexible())
                        )
                }
            }
            
            // Profile Info
            VStack(alignment: .leading, spacing: 4.flexible()) {
                Text(viewModel.user?.email ?? "")
                    .interRegular(size: 16.flexible())
                    .foregroundColor(.text1A1A1A)
            }
            
            Spacer()
        }
        .padding(20.flexible())
        .background(Color.white)
        .cornerRadius(16.flexible())
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Password Section
private extension EditProfileView {
    
    var passwordStack: some View {
        VStack(alignment: .leading, spacing: 4.flexible()) {
            BaseTextField(
                text: $viewModel.password,
                isError: viewModel.isPasswordError,
                keyboardType: .default,
                textContextType: .password,
                isSecureTextEntry: true,
                placeholder: "Password",
                onCommit: {}
            )
            .focused($isPasswordFocused)
            
            if isPasswordFocused || viewModel.isPasswordError {
                Text("Requirments: minimum 6 symbols")
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
}

// MARK: - Helpers
private extension EditProfileView {
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
