//
//  TabBarCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 17.02.2026.
//

import SwiftUI
import UIKit

protocol ChangeSelectedTab: AnyObject {
    func changeTab(to tab: Tab)
}

final class TabBarCoordinator: CompositionCoordinator {
    var finishDelegate: (any CoordinatorFinishDelegate)?
    var childCoordinators = [any Coordinator]()
    
    private let services: Services
    let tabBarController = MainTabBarController()
    
    private(set) var homeCoordinator: HomeMainCoordinator?
    private(set) var feedCoordinator: FeedCoordinator?
    private(set) var addBookCoordinator: AddBookCoordinator?
    private(set) var statsCoordinator: StatsCoordinator?
    private(set) var profileCoordinator: ProfileCoordinator?
    weak var delegate: TabBarCoordinatorDelegate?
    
    init(services: Services) {
        self.services = services
    }
    
    func start() {
        let homeNav = createHomeNavigation()
        let feedNav = createFeedNavigation()
        let addBookNav = createAddBookNavigation()
        let statsNav = createStatsNavigation()
        let profileNav = createProfileNavigation()
        
        homeCoordinator?.start()
        feedCoordinator?.start()
        addBookCoordinator?.start()
        statsCoordinator?.start()
        profileCoordinator?.start()
        
        tabBarController.viewControllers = [
            homeNav,
            feedNav,
            addBookNav,
            statsNav,
            profileNav
        ]
    }
    
    func createHomeNavigation() -> UINavigationController {
        let homeNav = UINavigationController()
        
        homeCoordinator = HomeMainCoordinator(
            navigationController: homeNav,
            services: services
        )
        homeCoordinator?.delegate = delegate
        
        return homeNav
    }
    
    func createFeedNavigation() -> UINavigationController {
        let feedNav = UINavigationController()
        
        feedCoordinator = FeedCoordinator(
            navigationController: feedNav,
            services: services
        )
        
        return feedNav
    }
    
    func createAddBookNavigation() -> UINavigationController {
        let addBookNav = UINavigationController()
        
        addBookCoordinator = AddBookCoordinator(
            navigationController: addBookNav,
            services: services
        )
        addBookCoordinator?.delegate = self
        
        return addBookNav
    }
    
    func createStatsNavigation() -> UINavigationController {
        let statsNav = UINavigationController()
        
        statsCoordinator = StatsCoordinator(
            navigationController: statsNav,
            services: services
        )
        
        return statsNav
    }
    
    func createProfileNavigation() -> UINavigationController {
        let profileNav = UINavigationController()
        
        profileCoordinator = ProfileCoordinator(
            navigationController: profileNav,
            services: services
        )
        profileCoordinator?.delegate = delegate
        
        return profileNav
    }
    
    func dismissAll(completion: @escaping () -> Void) {
        childCoordinators.forEach { $0.finish() }
        tabBarController.dismiss(animated: true, completion: completion)
    }
    
    deinit {
        print("Deinit TabBarCoordinator")
    }
}

extension TabBarCoordinator: ChangeSelectedTab {
    
    func changeTab(to tab: Tab) {
        self.tabBarController.changeSelectedTab(tab)
    }
}
