//
//  FlowCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 17.02.2026.
//

import UIKit

protocol FlowCoordinator: Coordinator {
    
    var childCoordinator: Coordinator? { get set }
}

extension FlowCoordinator {
    
    func addChild(_ coordinator: Coordinator) {
        childCoordinator = coordinator
        coordinator.finishDelegate = self
    }
    
    func removeChild() {
        childCoordinator = nil
    }
    
    func didFinish(childCoordinator: Coordinator) {
        removeChild()
    }
}
