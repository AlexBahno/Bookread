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
        let router = ProfileMainRouter(
            openSettings: { [weak self] in
                self?.openSetting()
            },
            openEdit: { [weak self] in
                self?.openEditView()
            },
            signOut: { [weak self] in
                self?.finish()
            }
        )
        let viewModel = ProfileMainViewModel(services: services, router: router)
        let profileMainView = ProfileMainView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: profileMainView)
        topNavigationController.pushViewController(vc, animated: true)
    }
    
    func openSetting(animeted: Bool = true) {
        let router = SettingsRouter(
            logOut: { [weak self] in
                self?.delegate?.didLogout()
            },
            openEdit: { [weak self] user in
                self?.openEditView()
            }
        )
        let viewModel = SettingsViewModel(services: services, router: router)
        let settingsView = SettingsView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: settingsView)
        topNavigationController.pushViewController(vc, animated: animeted)
    }
    
    func openEditView(animeted: Bool = true) {
        let viewModel = EditProfileViewModel(services: services)
        let editView = EditProfileView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: editView)
        topNavigationController.pushViewController(vc, animated: animeted)
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
