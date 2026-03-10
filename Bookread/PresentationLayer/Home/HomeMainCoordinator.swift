//
//  HomeMainCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 10.03.2026.
//

import UIKit
import SwiftUI

final class HomeMainCoordinator {
    private var childCoordinator: Coordinator?
    private let services: Services
    weak var delegate: TabBarCoordinatorDelegate?
    
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
//        let homeVM = HomeViewModel()
        
        var homeView = HomeMainView()
        homeView.logout = { [weak self] in
            self?.delegate?.didLogout()
        }
        let hostingController = UIHostingController(rootView: homeView)
        
        startNavigationController.pushViewController(hostingController, animated: false)
    }
}
