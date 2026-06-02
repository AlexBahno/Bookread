//
//  FeedCellViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 02/06/2026.
//

import Combine

@MainActor
final class FeedCellViewModel: ObservableObject {
    
    @Published var isLiked: Bool = false
    private var feedItem: FeedItem
    private let openProfile: (AppUser) -> Void
    
    private let feedService: FB_FeedServiceProtocol
    private let sessionService: SessionServiceProtocol
    
    init(
        feedItem: FeedItem,
        feedService: FB_FeedServiceProtocol,
        sessionService: SessionServiceProtocol,
        openProfile: @escaping (AppUser) -> Void
    ) {
        self.feedItem = feedItem
        self.openProfile = openProfile
        self.sessionService = sessionService
        self.feedService = feedService
        
        self.isLiked = feedItem.session.likedBy?.contains(sessionService.currentUserId) ?? false
    }
    
    var book: UserBook {
        feedItem.book
    }
    
    var session: ReadingSession {
        feedItem.session
    }
    
    var owner: AppUser {
        feedItem.user
    }
        
    func toggleLike() {
        let currentUserId = sessionService.currentUserId
        
        let previousState = isLiked
        isLiked.toggle()
        
        if isLiked {
            if session.likedBy == nil { feedItem.session.likedBy = [] }
            feedItem.session.likedBy?.append(currentUserId)
        } else {
            feedItem.session.likedBy?.removeAll { $0 == currentUserId }
        }
        
        Task {
            do {
                guard let sessionId = session.id  else { return }
                
                try await feedService.toggleLike(
                    for: sessionId,
                    ownerId: session.userId,
                    isCurrentlyLiked: previousState
                )
            } catch {
                print("Failed to toggle like: \(error)")
                self.isLiked = previousState
                if previousState {
                    feedItem.session.likedBy?.append(currentUserId)
                } else {
                    feedItem.session.likedBy?.removeAll { $0 == currentUserId }
                }
            }
        }
    }
    
    func openOwnersProfile() {
        openProfile(self.owner)
    }
}
