//
//  SettingsView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 16/05/2026.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    
    @State private var showingImagePicker = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingLogOutAlert = false
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundFAFAF8)
            .navigationTitle("Settings")
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
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount()
                    }
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
            .alert("Log Out", isPresented: $showingLogOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    viewModel.logOut()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 20.flexible()) {
                profileSection
                
                // Account Section
                sectionGroup(title: "ACCOUNT") {
                    settingsRow(
                        icon: "person",
                        iconColor: .primary2D5F5D,
                        title: "Edit Profile",
                        tapAction: { print ("Edit") }
                    )
                    
                    settingsRow(
                        icon: "lock",
                        iconColor: .accentC17767,
                        title: "Change Password",
                        tapAction: { print("Change") }
                    )
                }
                
                sectionGroup(title: "SUPPORT") {
                    settingsRow(
                        icon: "questionmark.circle",
                        iconColor: Color(red: 1.0, green: 0.34, blue: 0.13),
                        title: "Help Center",
                        tapAction: {}
                    )
                    
                    settingsRow(
                        icon: "shield",
                        iconColor: .gray,
                        title: "Privacy Policy",
                        tapAction: {}
                    )
                    
                    settingsRow(
                        icon: "info.circle",
                        iconColor: .gray,
                        title: "About",
                        trailingText: "v\(viewModel.appVersion)",
                        showTrailingIcon: false,
                        tapAction: {}
                    )
                }
                
                sectionGroup(title: nil) {
                    settingsRow(
                        icon: "trash",
                        iconColor: .red,
                        title: "Delete Account",
                        titleColor: .red,
                        tapAction: { showingDeleteAccountAlert = true }
                    )
                    
                    settingsRow(
                        icon: "arrow.right.square",
                        iconColor: .red,
                        title: "Log Out",
                        titleColor: .red,
                        tapAction: { showingLogOutAlert = true }
                    )
                }
            }
            .padding(.top, 10.flexible())
            .padding(.horizontal, 16.flexible())
        }
    }
}

// MARK: - Sections
private extension SettingsView {
    
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
                Text(viewModel.userName)
                    .interRegular(size: 20.flexible())
                    .fontWeight(.semibold)
                
                Text(viewModel.userEmail)
                    .interRegular(size: 16.flexible())
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(20.flexible())
        .background(Color.white)
        .cornerRadius(16.flexible())
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Helpers
private extension SettingsView {
    
    @ViewBuilder
    private func sectionGroup<Content: View>(
        title: String?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8.flexible()) {
            if let title = title {
                Text(title)
                    .interRegular(size: 14.flexible())
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4.flexible())
            }
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color.white)
            .cornerRadius(16.flexible())
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    
    @ViewBuilder
    func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        titleColor: Color = .text1A1A1A,
        trailingText: String? = nil,
        showTrailingIcon: Bool = true,
        tapAction: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12.flexible()) {
            iconView(icon: icon, color: iconColor)
            
            Text(title)
                .interRegular(size: 16.flexible())
                .foregroundColor(titleColor)
            
            Spacer()
            
            if let trailingText = trailingText {
                Text(trailingText)
                    .interRegular(size: 14.flexible())
                    .foregroundColor(.gray)
            }
            
            if !showTrailingIcon {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14.flexible(), weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(16.flexible())
        .onTapGesture {
            tapAction()
        }
    }
    
    private func iconView(icon: String, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 8.flexible())
            .fill(color.opacity(0.15))
            .frame(width: 32.flexible(), height: 32.flexible())
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 16.flexible()))
                    .foregroundColor(color)
            )
    }
}
