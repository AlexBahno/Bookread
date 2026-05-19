//
//  ProfileMainViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 21.03.2026.
//

import Foundation
import Combine

struct ProfileMainRouter {
    let openSettings: () -> Void
    let signOut: () -> Void
}

@MainActor
final class ProfileMainViewModel: ObservableObject {
    
    @Published private(set) var user: AppUser?
    @Published var recentSessions: [ReadingSession] = []
    private var activityTask: Task<Void, Never>?
    
    private let firebaseService: FirebaseServiceProtocol
    private let sessionService: SessionServiceProtocol
    private let router: ProfileMainRouter
    
    private var cancellables = Set<AnyCancellable>()
    
    var isPersonalAccount: Bool {
        sessionService.currentUser?.id == user?.id
    }
    
    init(
        services: Services,
        router: ProfileMainRouter
    ) {
        self.firebaseService = services.firebaseService
        self.sessionService = services.sessionService
        self.router = router
        
        self.sessionService.currentUserPublisher
            .sink { [weak self] fetchedUser in
                self?.user = fetchedUser
            }
            .store(in: &cancellables)
    }
    
    func loadRecentActivity() {
        activityTask = Task {
            do {
                for try await sessions in firebaseService.recentActivityStream(limit: 20) {
                    self.recentSessions = sessions
                }
            } catch {
                print(error)
            }
        }
    }
    
    func stopActivity() { activityTask?.cancel() }
    
    func openSettings() {
        router.openSettings()
    }
    
    func signOut() {
        router.signOut()
    }
}
