//
//  FeedMainViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29/05/2026.
//

import Foundation
import Combine

struct FeedMainRouter {
    let openProfile: (AppUser) -> Void
}

final class FeedMainViewModel: ObservableObject {
    
    @Published var feed: [FeedItem] = []
    @Published var isLoading = false
    
    @Published var searchQuery: String = ""
    @Published var searchResult: [AppUser] = []
    
    private(set) var  feedService: FB_FeedServiceProtocol
    private let userService: FB_UserServiceProtocol
    private(set) var sessionsService: SessionServiceProtocol
    private let router: FeedMainRouter
    
    private var cancellables = Set<AnyCancellable>()
    
    init(services: Services, router: FeedMainRouter) {
        self.feedService = services.feedService
        self.userService = services.userService
        self.sessionsService = services.sessionService
        self.router = router
    }
    
    func setupSearchDebounce() {
        guard cancellables.isEmpty else { return }
        
        $searchQuery
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
//            .filter { $0.count >= 2 }
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    func loadFeed() {
        isLoading = true
        Task {
            do {
                self.feed = try await feedService.fetchFeedWithoutDuplication()
            } catch {
                print("Failed to load feed: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func openProfilePage(user: AppUser) {
        router.openProfile(user)
    }
}

// MARK: - Search Field
private extension FeedMainViewModel {
    
    func performSearch(query: String) {
        guard !query.isEmpty else {
            self.searchResult = []
            return
        }
        
        self.isLoading = true
        
        Task {
            do {
                self.searchResult = try await userService.searchUsers(with: query)
            } catch {
                print("Помилка пошуку користувачів: \(error)")
            }
            self.isLoading = false
        }
    }
}
