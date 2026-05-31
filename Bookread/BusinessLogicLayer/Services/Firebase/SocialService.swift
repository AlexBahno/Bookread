//
//  SocialService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29/05/2026.
//

import FirebaseFirestore
import FirebaseAuth

protocol SocialServiceProtocol {
    
    func followUser(targetUserId: String) async throws
    func unfollowUser(targetUserId: String) async throws
    func checkIsFollowing(targetUserId: String) async throws -> Bool
    func fetchFollowStats(for userId: String) async throws -> (followers: Int, following: Int)
}

final class SocialService: SocialServiceProtocol {
    
    private let db = Firestore.firestore()
    
    /// Follows a user using a Batched Write
    func followUser(targetUserId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        
        let myFollowingRef = db.collection("users").document(currentUserId).collection("following").document(targetUserId)
        let targetFollowerRef = db.collection("users").document(targetUserId).collection("followers").document(currentUserId)
        
        batch.setData(["timestamp": FieldValue.serverTimestamp()], forDocument: myFollowingRef)
        batch.setData(["timestamp": FieldValue.serverTimestamp()], forDocument: targetFollowerRef)
        
        try await batch.commit()
    }
    
    /// Unfollows a user
    func unfollowUser(targetUserId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        
        let myFollowingRef = db.collection("users").document(currentUserId).collection("following").document(targetUserId)
        let targetFollowerRef = db.collection("users").document(targetUserId).collection("followers").document(currentUserId)
        
        batch.deleteDocument(myFollowingRef)
        batch.deleteDocument(targetFollowerRef)
        
        try await batch.commit()
    }
    
    func checkIsFollowing(targetUserId: String) async throws -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return false
        }
        
        let followingRef = db.collection("users")
            .document(currentUserId)
            .collection("following")
            .document(targetUserId)
        
        let documentSnapshot = try await followingRef.getDocument()
        
        return documentSnapshot.exists
    }
    
    func fetchFollowStats(for userId: String) async throws -> (followers: Int, following: Int) {
        let userDocRef = db.collection("users").document(userId)
        
        let followersQuery = userDocRef.collection("followers").count
        let followingQuery = userDocRef.collection("following").count
        
        async let followersSnapshot = followersQuery.getAggregation(source: .server)
        async let followingSnapshot = followingQuery.getAggregation(source: .server)
        
        let (followersResult, followingResult) = try await (followersSnapshot, followingSnapshot)
        
        let followersCount = Int(truncating: followersResult.count)
        let followingCount = Int(truncating: followingResult.count)
        
        return (followersCount, followingCount)
    }
}
