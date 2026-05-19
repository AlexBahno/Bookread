//
//  ProfileImageService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 16/05/2026.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

enum ImageUploadError: Error {
    case compressionFailed
    case userNotAuthenticated
}

protocol ProfileImageServiceProtocol {
    
    func uploadAndUpdateProfileImage(_ image: UIImage) async throws -> String
}

final class ProfileImageService: ProfileImageServiceProtocol {
    
    /// Uploads a UIImage to Firebase Storage and updates the Firestore user profile.
    /// - Parameter image: The UIImage selected by the user.
    /// - Returns: The absolute URL string of the uploaded image.
    func uploadAndUpdateProfileImage(_ image: UIImage) async throws -> String {
        // 1. Ensure user is authenticated to get their UID
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw ImageUploadError.userNotAuthenticated
        }
        
        // 2. Compress the UIImage to optimize network traffic and storage
        // A compression quality between 0.5 and 0.8 is usually a good balance.
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw ImageUploadError.compressionFailed
        }
        
        // 3. Create a reference to Firebase Storage
        let storageRef = Storage.storage().reference()
        let profileImageRef = storageRef.child("users/\(currentUserId)/profile_image.jpg")
        
        // 4. Set metadata (optional but recommended)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 5. Upload the data
        _ = try await profileImageRef.putDataAsync(imageData, metadata: metadata)
        
        // 6. Retrieve the download URL
        let downloadURL = try await profileImageRef.downloadURL()
        let urlString = downloadURL.absoluteString
        
        // 7. Update the user's document in Firestore
        let db = Firestore.firestore()
        try await db.collection("users").document(currentUserId).updateData([
            "profileImageUrl": urlString
        ])
        
        return urlString
    }
}
