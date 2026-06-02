//
//  FB_UserService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 02/06/2026.
//

import Foundation
import FirebaseAuth
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

protocol FB_UserServiceProtocol {
    
    // user
    func getCurrentUser() -> User?
    func getUserBy(id: String) async throws -> AppUser?
    func updateUser(
        with uid: String,
        updatedData: [String: Any]
    ) async -> Bool
    func searchUsers(with query: String) async throws -> [AppUser]
}

final class FB_UserService: FB_UserServiceProtocol {
    
    let auth = Auth.auth()
    let firestore = Firestore.firestore()
    
    func getCurrentUser() -> User? {
        auth.currentUser
    }
    
    func getUserBy(id: String) async throws -> AppUser? {
        let userRef = firestore.collection("users").document(id)
        
        do {
            let userProfile = try await userRef.getDocument(as: AppUser.self)
            return userProfile
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func updateUser(
        with uid: String,
        updatedData: [String: Any]
    ) async -> Bool {
        do {
            try await firestore
                .collection("users")
                .document(uid)
                .updateData(updatedData)
            
            return true
        } catch {
            print("User with id \(uid) wasnt updated")
            return false
        }
    }
    
    func searchUsers(with query: String) async throws -> [AppUser] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        
        let currentUserId = auth.currentUser?.uid
        
        let lowercasedQuery = query.lowercased()
        
        let snapshot = try await firestore.collection("users")
            .whereField("searchableName", isGreaterThanOrEqualTo: lowercasedQuery)
            .whereField("searchableName", isLessThanOrEqualTo: lowercasedQuery + "\u{f8ff}")
            .limit(to: 20)
            .getDocuments()
        
        let users = snapshot.documents.compactMap { document -> AppUser? in
            guard document.documentID != currentUserId else { return nil }
            return try? document.data(as: AppUser.self)
        }
        
        return users
    }
}
