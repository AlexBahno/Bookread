//
//  StatsCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 25/05/2026.
//

import UIKit
import SwiftUI

final class StatsCoordinator {
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
        let viewModel = StatsViewModel(services: services)
        let statsView = StatsView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: statsView)
        topNavigationController.pushViewController(vc, animated: true)
    }
}
