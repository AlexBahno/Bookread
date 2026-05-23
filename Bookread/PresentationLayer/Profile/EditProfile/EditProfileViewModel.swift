//
//  EditProfileViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 19/05/2026.
//

import Combine
import UIKit
import _PhotosUI_SwiftUI

@MainActor
final class EditProfileViewModel: ObservableObject {
    
    @Published private(set) var user: AppUser?
    var originalImage: UIImage? = nil
    
    @Published var username: String = ""
    @Published var profileImage: UIImage? = nil
    @Published var password = ""
    @Published var selectedPhoto: PhotosPickerItem? {
        didSet {
            Task {
                await loadPhoto()
            }
        }
    }
    
    @Published var isPasswordError = false
    @Published var isButtonDisabled: Bool = true
    
    private let sessionService: SessionServiceProtocol
    private let authService: AuthServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let firebaseService: FirebaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var isLoading = false
    
    init(services: Services) {
        self.sessionService = services.sessionService
        self.authService = services.authService
        self.profileImageService = services.profileImageService
        self.firebaseService = services.firebaseService
        
        self.sessionService.currentUserPublisher
            .sink { [weak self] fetchedUser in
                self?.user = fetchedUser
            }
            .store(in: &cancellables)
        
        self.username = self.user?.username ?? ""
        user?.loadImage { [weak self] image in
            self?.originalImage = image
            self?.profileImage = image
        }
    }
    
    var hasChanges: Bool {
        return username != user?.username ||
        profileImage != originalImage
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
    
    func removePhoto() {
        profileImage = nil
        selectedPhoto = nil
    }
    
    func isValidPassword() -> Bool {
        let pattern = #"^[A-Z0-9a-z._+-=]{6,}$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(password.startIndex..., in: password)
        return regex?.firstMatch(in: password, options: [], range: range) != nil
    }
    
    func checkPasswordError() {
        self.isPasswordError = !self.isValidPassword()
    }
    
    func changePassword() async {
        isLoading = true
        do {
            try await authService.changePassword(to: password)
            
            self.password = ""
            isPasswordError = false
            isLoading = false
        } catch {
            isPasswordError = true
            isButtonDisabled = true
            isLoading = false
            print(error.localizedDescription)
        }
    }
}
