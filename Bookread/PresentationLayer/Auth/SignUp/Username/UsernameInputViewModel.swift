//
//  UsernameInputViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 08.03.2026.
//

import Combine
import FirebaseStorage
import FirebaseFirestoreInternal
import Foundation

final class UsernameInputViewModel: ObservableObject {
    
    // MARK: - Properties
    private let uid: String
    private var firebaseService: FirebaseServiceProtocol
    
    @Published var username: String = ""
    @Published var isLoading: Bool = false
    
    @Published private(set) var isUsernameError = false
    @Published var underFieldMessage = "Requirments: 3-20 charachters, no spaces"
    
    // MARK: - Coordinator Routing
    private var onProfileCompleted: (() -> Void)?
    
    init(
        uid: String,
        firebaseService: FirebaseServiceProtocol,
        onProfileCompleted: @escaping () -> Void
    ) {
        self.uid = uid
        self.firebaseService = firebaseService
        self.onProfileCompleted = onProfileCompleted
    }
    
    // MARK: - Logic
    func saveUsername() {
        isLoading = true
        
        Task {
            do {
                // 2. Check Firestore to see if the username is already taken
                let isAvailable = try await checkUsernameAvailability(username: username)
                
                guard isAvailable else {
                    self.underFieldMessage = "This username is already taken. Please choose another."
                    self.isLoading = false
                    return
                }
                
                // 3. Save to Firestore
                // CRITICAL: We use `setData` with `merge: true` instead of `updateData`.
                // If the user's internet is super fast and they submit this before the backend
                // Cloud Function finishes making the document, updateData would crash.
                // Merge guarantees it works safely regardless of timing.
                try await firebaseService
                    .getFirestore()
                    .collection("users")
                    .document(uid)
                    .updateData(
                        ["username": username]
                    )
                
                // 4. Success! Tell the coordinator to take us to the main app.
                self.onProfileCompleted?()
                
            } catch {
                self.underFieldMessage = "Failed to save username."
            }
            
            isLoading = false
        }
    }
    
    // Helper function to isolate the database query
    private func checkUsernameAvailability(username: String) async throws -> Bool {
        let snapshot = try await firebaseService
            .getFirestore()
            .collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()
        
        // If the snapshot is empty, nobody else has this username
        return snapshot.isEmpty
    }
}

// MARK: - Check states of fields
extension UsernameInputViewModel {
    
    func checkUsernameError() {
        self.isUsernameError = !self.isValidUsername()
    }
}

// MARK: - isValid function
private extension UsernameInputViewModel {
    
    func isValidUsername() -> Bool {
        let pattern = #"^[A-Z0-9a-z._-]{3,20}$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(username.startIndex..., in: username)
        return regex?.firstMatch(in: username, options: [], range: range) != nil
    }
}
