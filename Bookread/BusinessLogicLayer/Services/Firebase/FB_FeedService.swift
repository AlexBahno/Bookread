//
//  FeedService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29/05/2026.
//

import FirebaseFirestore
import FirebaseAuth

struct FeedItem: Identifiable {
    let id: String
    var session: ReadingSession
    let user: AppUser
    let book: UserBook
}

protocol FB_FeedServiceProtocol {
    
    func fetchFeedWithoutDuplication() async throws -> [FeedItem]
    func toggleLike(for sessionId: String, ownerId: String, isCurrentlyLiked: Bool) async throws
}

final class FB_FeedService: FB_FeedServiceProtocol {
    
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    
    func fetchFeedWithoutDuplication() async throws -> [FeedItem] {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return [] }
        
        let followingSnapshot = try await firestore.collection("users")
            .document(currentUserId)
            .collection("following")
            .getDocuments()
        let followingIds = followingSnapshot.documents.map { $0.documentID }
        guard !followingIds.isEmpty else { return [] }
        
        let idsToQuery = Array(followingIds.prefix(30))
        
        let sessionsSnapshot = try await firestore.collectionGroup("readingSessions")
            .whereField("userId", in: idsToQuery)
            .order(by: "endTime", descending: true)
            .limit(to: 20)
            .getDocuments()
        
        var feedItems: [FeedItem] = []
        
        for document in sessionsSnapshot.documents {
            guard let session = try? document.data(as: ReadingSession.self) else { continue }
            
            let userDoc = try await firestore.collection("users").document(session.userId).getDocument()
            guard let user = try? userDoc.data(as: AppUser.self) else { continue }
            
            let bookDoc = try await firestore.collection("users")
                .document(session.userId)
                .collection("userBooks")
                .document(session.bookId)
                .getDocument()
            guard let book = try? bookDoc.data(as: UserBook.self) else { continue }
            
            feedItems.append(FeedItem(id: session.id ?? UUID().uuidString, session: session, user: user, book: book))
        }
        
        return feedItems
    }
    
    func toggleLike(for sessionId: String, ownerId: String, isCurrentlyLiked: Bool) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let sessionRef = firestore.collection("users")
            .document(ownerId)
            .collection("readingSessions")
            .document(sessionId)
        
        if isCurrentlyLiked {
            try await sessionRef.updateData([
                "likedBy": FieldValue.arrayRemove([currentUserId])
            ])
        } else {
            try await sessionRef.updateData([
                "likedBy": FieldValue.arrayUnion([currentUserId])
            ])
        }
    }
}
