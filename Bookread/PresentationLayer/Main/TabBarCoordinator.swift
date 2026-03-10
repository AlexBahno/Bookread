//
//  TabBarCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 17.02.2026.
//

import SwiftUI
import UIKit

final class TabBarCoordinator: CompositionCoordinator {
    var finishDelegate: (any CoordinatorFinishDelegate)?
    var childCoordinators = [any Coordinator]()
    
    private let services: Services
    let tabBarController = MainTabBarController()
    
    private(set) var homeCoordinator: HomeMainCoordinator?
    //    private(set) var secondTabCoordinator: SecondTabCoordinator?
    weak var delegate: TabBarCoordinatorDelegate?
    
    
    init(services: Services) {
        self.services = services
    }
    
    func start() {
        let homeNav = UINavigationController()
        homeCoordinator = HomeMainCoordinator(
            navigationController: homeNav,
            services: services
        )
        homeCoordinator?.delegate = delegate
        
        homeCoordinator?.start()
        tabBarController.viewControllers = [homeNav, UINavigationController(), UINavigationController(), UINavigationController()]
    }
    
    func dismissAll(completion: @escaping () -> Void) {
        childCoordinators.forEach { $0.finish() }
        tabBarController.dismiss(animated: true, completion: completion)
    }
    
    deinit {
        print("Deinit TabBarCoordinator")
    }
}
