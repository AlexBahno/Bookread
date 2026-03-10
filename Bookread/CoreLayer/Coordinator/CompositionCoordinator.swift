//
//  CompositionCoordinator.swift
//  Bookread
//
//  Created by Alexandr Bahno on 17.02.2026.
//

import UIKit

protocol CompositionCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] { get set }
}

extension CompositionCoordinator {
    
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    func didFinish(childCoordinator: Coordinator) {
        removeChild(childCoordinator)
    }
}
