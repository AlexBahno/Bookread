//
//  ProfileCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 21.03.2026.
//

import Foundation
import UIKit
import SwiftUI

final class ProfileCoordinator {
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
        let router = ProfileMainRouter()
        let viewModel = ProfileMainViewModel(services: services, router: router)
        let profileMainView = ProfileMainView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: profileMainView)
        topNavigationController.pushViewController(vc, animated: true)
    }
    
    func popLast(animated: Bool = true) {
        topNavigationController.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool = true) {
        topNavigationController.popToRootViewController(animated: animated)
    }
    
    // MARK: - Flow Completion
    func finish() {
        delegate?.didLogout()
    }
}
