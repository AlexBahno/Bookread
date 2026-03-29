//
//  AddBookCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 24.03.2026.
//

import UIKit
import SwiftUI

final class AddBookCoordinator {
    private var childCoordinator: Coordinator?
    private let services: Services
    weak var delegate: ChangeSelectedTab?
    
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
        let router = SearchRouter(
            openScanner: { [weak self] in
                self?.openScanner()
            },
            openBookView: { [weak self] book in
                self?.openBookView(book)
            }
        )
        let viewModel = SearchViewModel(
            networkService: services.networkService,
            router: router
        )
        let searchView = SearchView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: searchView)
        topNavigationController.pushViewController(vc, animated: true)
    }
    
    func openScanner(animated: Bool = true) {
        let router = ScannerViewRouter { [weak self] in
            self?.delegate?.changeTab(to: .home)
            self?.popToRoot()
        }
        let viewModel = ScannerQRViewModel(
            networkService: services.networkService,
            router: router
        )
        let view = ScannerQRMainView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: view)
        topNavigationController.pushViewController(vc, animated: animated)
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
    
    func popLast(animated: Bool = true) {
        topNavigationController.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool = true) {
        topNavigationController.popToRootViewController(animated: animated)
    }
    
    // MARK: - Flow Completion
    func finish() {
    }
}

