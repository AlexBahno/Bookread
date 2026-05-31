//
//  FeedCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29/05/2026.
//

import Foundation

import UIKit
import SwiftUI

final class FeedCoordinator {
    private var childCoordinator: Coordinator?
    private let services: Services
    
    private let startNavigationController: UINavigationController
    private var navigationControllers = [UINavigationController]()
    
    private var topNavigationController: UINavigationController {
        navigationControllers.last ?? startNavigationController
    }
    private var rootNavigationController: UINavigationController {
        navigationControllers.first ?? startNavigationController
    }
    private var routePresentationDelegates = [PresentationDelegate]()
    
    var pushedDepth: Int {
        topNavigationController.viewControllers.count - 1
    }
    var presentedDepth: Int {
        navigationControllers.count - 1
    }
    
    init(
        navigationController: UINavigationController,
        services: Services
    ) {
        startNavigationController = navigationController
        self.services = services
    }
    
    func start() {
        let router = FeedMainRouter(
            openProfile: { [weak self] user in
                self?.openProfile(user: user)
            }
        )
        let viewModel = FeedMainViewModel(services: services, router: router)
        let view = FeedMainView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: view)
        topNavigationController.pushViewController(vc, animated: true)
    }
    
    func openProfile(user: AppUser) {
        let router = ProfileMainRouter(
            openEdit: {},
            signOut: {}
        )
        let viewModel = ProfileMainViewModel(userID: user.id, services: services, router: router)
        let profileMainView = ProfileMainView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: profileMainView)
        topNavigationController.pushViewController(vc, animated: true)
    }
}
