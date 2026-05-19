//
//  SettingsViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 16/05/2026.
//

import Foundation
import Combine
import UIKit
import _PhotosUI_SwiftUI

struct SettingsRouter {
    let logOut: () -> Void
}

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published private(set) var user: AppUser?
    @Published var profileImage: UIImage?
    @Published var selectedPhoto: PhotosPickerItem? {
        didSet {
            Task {
                await loadPhoto()
            }
        }
    }
    
    private let firebaseService: FirebaseServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let sessionService: SessionServiceProtocol
    private let authService: AuthServiceProtocol
    private let router: SettingsRouter
    
    private var cancellables = Set<AnyCancellable>()
    
    var userName: String {
        user?.username ?? ""
    }
    
    var userEmail: String {
        user?.email ?? ""
    }
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    init(
        services: Services,
        router: SettingsRouter
    ) {
        self.firebaseService = services.firebaseService
        self.sessionService = services.sessionService
        self.profileImageService = services.profileImageService
        self.authService = services.authService
        self.router = router
        
        self.sessionService.currentUserPublisher
            .sink { [weak self] fetchedUser in
                self?.user = fetchedUser
            }
            .store(in: &cancellables)
    }
    
    private func loadPhoto() async {
        guard let selectedPhoto = selectedPhoto else { return }
        
        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.profileImage = image
                let newUrl = try await
                        self.profileImageService.uploadAndUpdateProfileImage(image)
                if let user {
                    _ = await firebaseService.updateUser(with: user.id, updatedData: [
                        "profileImageUrl" : newUrl
                    ])
                }
          
            }
        } catch {
            print("Failed to load photo: \(error)")
        }
    }
    
    func deleteAccount() async {
        do {
            try await authService.deleteAccount()
            logOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func logOut() {
        router.logOut()
    }
}
