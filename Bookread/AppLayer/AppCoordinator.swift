//
//  AppCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 08.03.2026.
//

import UIKit
import FirebaseAuth
import SwiftUI

// MARK: - Delegate Protocols
// These protocols allow child coordinators to communicate back up to the AppCoordinator
protocol AuthCoordinatorDelegate: AnyObject {
    func didFinishAuth()
}

protocol TabBarCoordinatorDelegate: AnyObject {
    func didLogout()
}

// MARK: - AppCoordinator
class AppCoordinator: AuthCoordinatorDelegate, TabBarCoordinatorDelegate {
    
    // The main window of the application
    private let window: UIWindow
    private let services: Services
    
    // Strong references to child coordinators to keep them alive in memory
    private var authCoordinator: AuthCoordinator?
    private var tabBarCoordinator: TabBarCoordinator?
    
    init(
        window: UIWindow,
        services: Services
    ) {
        self.window = window
        self.services = services
    }
    
    // The entry point called by your SceneDelegate
    func start() {
        showSplashScreen()
    }
    
    private func showSplashScreen() {
        var splashView = SplashScreenView()
        splashView.animationEnds = { [weak self] in
            self?.evaluateAuthState()
        }
        let splashVC = UIHostingController(rootView: splashView)
        setRootViewController(splashVC)
    }
    
    private func evaluateAuthState() {
        // Now we check if the user is logged in
        if Auth.auth().currentUser != nil {
            showMainApp()
        } else {
            showAuth()
        }
    }
    
    // MARK: - Flow Management
    private func showAuth() {
        // 1. Create a fresh Navigation Controller for the Auth flow
        let navigationController = UINavigationController()
        
        // 2. Initialize the AuthCoordinator and set the delegate
        authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            services: services
        )
        authCoordinator?.delegate = self
        
        // 3. Start the flow and set it as the root
        authCoordinator?.start()
        setRootViewController(navigationController)
        
        // 4. Free up memory by destroying the TabBarCoordinator if it existed (e.g., after logout)
        tabBarCoordinator = nil
    }
    
    private func showMainApp() {
        if let uid = services.firebaseService.getCurrentUser()?.uid {
            services.sessionService.startSession(uid: uid)
        }
        
        tabBarCoordinator = TabBarCoordinator(services: services)
        tabBarCoordinator?.delegate = self
        
        tabBarCoordinator?.start()
        
        guard let tabBarController = tabBarCoordinator?.tabBarController else { return }
        setRootViewController(tabBarController)
        
        authCoordinator = nil
    }
    
    // MARK: - Helper Methods
    
    private func setRootViewController(_ viewController: UIViewController) {
        window.rootViewController = viewController
        
        // Add a smooth cross-dissolve animation when swapping the entire app flow
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
        
        window.makeKeyAndVisible()
    }
    
    // MARK: - Delegate Implementations
    
    // Called by AuthCoordinator when login/signup is completely finished
    func didFinishAuth() {
        showMainApp()
    }
    
    // Called by TabBarCoordinator (or a Profile/Settings child coordinator) when the user logs out
    func didLogout() {
        do {
            try Auth.auth().signOut()
            
            services.sessionService.endSession()
            
            showAuth()
        } catch {
            print("Error signing out of Firebase: \(error.localizedDescription)")
        }
    }
}
