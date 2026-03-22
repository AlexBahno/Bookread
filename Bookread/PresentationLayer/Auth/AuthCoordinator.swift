//
//  OnBoardingCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 17.02.2026.
//

import UIKit
import SwiftUI

final class AuthCoordinator {
    private var childCoordinator: Coordinator?
    private let services: Services
    weak var delegate: AuthCoordinatorDelegate?
    
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
        navigateToOnBoarding()
    }
    
    func navigateToOnBoarding(animated: Bool = true) {
        let router = OnBoardingRouter { [weak self] in
            self?.navigateToSignUp()
        } startLoginFlow: { [weak self] in
            self?.navigateToSingIn()
        }
        let onBoardingView = OnBoardingView(router: router)
        let onBoardingVC = UIHostingController(rootView: onBoardingView)
        topNavigationController.pushViewController(onBoardingVC, animated: animated)
    }
    
    func navigateToSingIn(animated: Bool = true) {
        let router = SignInRouter { [weak self] in
            self?.finish()
        }
        let viewModel = SignInViewModel(
            firebaseService: services.firebaseService,
            router: router
        )
        let signInView = SignInView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: signInView)
        topNavigationController.pushViewController(vc, animated: animated)
    }
    
    func navigateToSignUp(animated: Bool = true) {
        let router = SignUpRouter { [weak self] in
            self?.finish()
        } onNeedsUsername: { [weak self] uid in
            self?.navigateToCompleteProfile(uid: uid)
        }

        let viewModel = SignUpViewModel(
            firebaseService: services.firebaseService,
            router: router
        )
        let signUpView = SignUpView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: signUpView)
        topNavigationController.pushViewController(vc, animated: animated)
    }
    
    func navigateToCompleteProfile(uid: String, animated: Bool = true) {
        let viewModel = UsernameInputViewModel(
            uid: uid,
            firebaseService: services.firebaseService,
            onProfileCompleted: { [weak self] in
                self?.finish()
            }
        )
        let view = UsernameInputView(viewModel: viewModel)
        
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
        delegate?.didFinishAuth()
    }
}
