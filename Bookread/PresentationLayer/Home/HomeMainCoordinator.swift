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
        let router = HomeMainRouter(openBookView: { [weak self] book in
            self?.openBookView(book)
        })
        let homeVM = HomeMainViewModel(
            firebaseService: services.firebaseService,
            router: router
        )
        let homeView = HomeMainView(viewModel: homeVM)

        let hostingController = UIHostingController(rootView: homeView)
        startNavigationController.pushViewController(hostingController, animated: true)
    }
    
    func openBookView(_ book: UserBook, animated: Bool = true) {
        let viewModel = BookTimerViewModel(
            book: book,
            firebaseService: services.firebaseService
        )
        let view = BookTimerView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: view)
        topNavigationController.pushViewController(vc, animated: animated)
    }
}
