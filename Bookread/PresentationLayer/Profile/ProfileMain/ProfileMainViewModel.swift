//
//  ProfileMainViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 21.03.2026.
//

import Foundation
import Combine

struct ProfileMainRouter {
    let openEdit: () -> Void
    let signOut: () -> Void
}

@MainActor
final class ProfileMainViewModel: ObservableObject {
    
    @Published private(set) var user: AppUser?
    @Published var recentSessions: [ReadingSession] = []
    @Published var isFollowing: Bool = false
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var amountOfFinishedBooks: Int = 0
    
    private var activityTask: Task<Void, Never>?
    
    private let authService: FB_AuthServiceProtocol
    private let userService: FB_UserServiceProtocol
    private let sessionService: SessionServiceProtocol
    private let socialService: FB_SocialServiceProtocol
    private let bookService: FB_BookServiceProtocol
    private let readingSessionService: FB_ReadingSessionServiceProtocol
    
    private let router: ProfileMainRouter
    
    private var cancellables = Set<AnyCancellable>()
    
    var isPersonalAccount: Bool {
        sessionService.currentUser?.id == user?.id
    }
    
    init(
        // if userID = nil, then fetch current user`s data
        userID: String? = nil,
        services: Services,
        router: ProfileMainRouter
    ) {
        self.authService = services.authService
        self.userService = services.userService
        self.sessionService = services.sessionService
        self.socialService = services.socialService
        self.bookService = services.bookService
        self.readingSessionService = services.readingSessionService
        self.router = router
        
        if let userID {
            Task {
                await fetchOtherUserBy(id: userID)
            }
            loadRecentActivity(by: userID)
            fetchStats(by: userID)
            fetchFinishedBooks(by: userID)
        } else {
            setupCurrentUserSubscription()
            loadRecentActivity(by: sessionService.currentUserId)
            fetchStats(by: sessionService.currentUserId)
            fetchFinishedBooks(by: sessionService.currentUserId)
        }
    }
    
    func loadRecentActivity(by id: String) {
        activityTask = Task {
            do {
                for try await sessions in readingSessionService.recentActivityStream(
                    for: id,
                    limit: 20
                ) {
                    self.recentSessions = sessions
                }
            } catch {
                print(error)
            }
        }
    }
    
    func deleteAccount() async {
        do {
            try await authService.deleteAccount()
            signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchStats(by id: String) {
        Task {
            do {
                let stats = try await socialService.fetchFollowStats(for: id)
                self.followersCount = stats.followers
                self.followingCount = stats.following
            } catch {
                print("Помилка при завантаженні статистики підписок: \(error)")
            }
        }
    }
    
    func fetchFinishedBooks(by id: String) {
        Task {
            do {
                let stats = try await bookService.fetchUserBooks(userID: id)
                self.amountOfFinishedBooks = stats.count
            } catch {
                print("Помилка при завантаженні статистики книжок: \(error)")
            }
        }
    }
    
    func stopActivity() { activityTask?.cancel() }
}

// MARK: - Router function
extension ProfileMainViewModel {
    
    func openEdit() {
        router.openEdit()
    }
    
    func signOut() {
        router.signOut()
    }
}

// MARK: - Follow/Unfollow
extension ProfileMainViewModel {
    
    func checkIfFollowing() {
        Task {
            do {
                if let user {
                    self.isFollowing = try await socialService.checkIsFollowing(
                        targetUserId: user.id
                    )
                    
                }
            } catch {
                print("Помилка перевірки статусу підписки: \(error)")
            }
        }
    }
    
    func toggleFollowState() {
        guard let user = user else { return }
        let previousState = isFollowing
        isFollowing.toggle()
        
        if isFollowing {
            followersCount += 1
        } else {
            followersCount -= 1
        }
        
        Task {
            do {
                if previousState {
                    try await socialService.unfollowUser(targetUserId: user.id)
                } else {
                    try await socialService.followUser(targetUserId: user.id)
                }
            } catch {
                self.isFollowing = previousState
                print("Помилка зміни статусу підписки: \(error)")
            }
        }
    }
}

// MARK: - Fetch User
private extension ProfileMainViewModel {
    
    func setupCurrentUserSubscription() {
        self.sessionService.currentUserPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fetchedUser in
                self?.user = fetchedUser
            }
            .store(in: &cancellables)
    }
    
    func fetchOtherUserBy(id: String) async {
        do {
            let fetchedUser = try await userService.getUserBy(id: id)
            self.user = fetchedUser
            self.checkIfFollowing()
        } catch {
            print("Failed to fetch user profile: \(error.localizedDescription)")
        }
    }
}
