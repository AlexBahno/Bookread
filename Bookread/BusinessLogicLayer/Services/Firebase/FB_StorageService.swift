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

protocol FB_StorageServiceProtocol {
    
    func uploadAndUpdateProfileImage(_ image: UIImage) async throws -> String
    func uploadOwnBookCover(bookID: String, _ image: UIImage) async throws -> String
}

final class FB_StorageService: FB_StorageServiceProtocol {
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    private let storage = Storage.storage()
    
    /// Uploads a UIImage to Firebase Storage and updates the Firestore user profile.
    /// - Parameter image: The UIImage selected by the user.
    /// - Returns: The absolute URL string of the uploaded image.
    func uploadAndUpdateProfileImage(_ image: UIImage) async throws -> String {
        guard let currentUserId = auth.currentUser?.uid else {
            throw ImageUploadError.userNotAuthenticated
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw ImageUploadError.compressionFailed
        }
        
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("users/\(currentUserId)/profile_image.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await profileImageRef.putDataAsync(imageData, metadata: metadata)
        
        let downloadURL = try await profileImageRef.downloadURL()
        let urlString = downloadURL.absoluteString
        
        try await firestore.collection("users").document(currentUserId).updateData([
            "profileImageUrl": urlString
        ])
        
        return urlString
    }
    
    func uploadOwnBookCover(bookID: String, _ image: UIImage) async throws -> String {
        guard let currentUserId = auth.currentUser?.uid else {
            throw ImageUploadError.userNotAuthenticated
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw ImageUploadError.compressionFailed
        }
        
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("users/\(currentUserId)/ownBookCover/\(bookID).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await profileImageRef.putDataAsync(imageData, metadata: metadata)
        
        let downloadURL = try await profileImageRef.downloadURL()
        let urlString = downloadURL.absoluteString
        
        return urlString
    }
}
