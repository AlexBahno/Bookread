//
//  ProfileMainViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 21.03.2026.
//

import Foundation
import Combine

struct ProfileMainRouter {
    
}

final class ProfileMainViewModel: ObservableObject {
    
    @Published private(set) var user: AppUser?
    
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
}
