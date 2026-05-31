//
//  MainTabBarController.swift
//  Bookread
//
//  Created by Alexandr Bahno on 10.03.2026.
//

import UIKit
import SnapKit
import SwiftUI
import Combine

@MainActor
class TabBarManager: ObservableObject {
    static let shared = TabBarManager()
    
    @Published var isHidden: Bool = false
    
    private init() {}
    
    func hide() { isHidden = true }
    func show() { isHidden = false }
}

final class MainTabBarController: UITabBarController {
    
    private let tabBarState = TabBarState()
    private var customTabBarView = UIView()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = true
        
        setCustomView()
        listenForVisibilityChanges()
        
        tabBarState.$selectedTab
            .sink { tab in
                self.selectedIndex = tab.rawValue
            }
            .store(in: &cancellables)
    }
    
    func changeSelectedTab(_ tab: Tab) {
        tabBarState.selectedTab = tab
    }
    
    // MARK: - The Combine Bridge
    private func listenForVisibilityChanges() {
        TabBarManager.shared.$isHidden
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHidden in
                self?.animateTabBar(hide: isHidden)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - The Animation Physics
    private func animateTabBar(hide: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            if hide {
                let offset = self.customTabBarView.bounds.height + self.view.safeAreaInsets.bottom
                self.customTabBarView.transform = CGAffineTransform(translationX: 0, y: offset)
                self.customTabBarView.alpha = 0
            } else {
                self.customTabBarView.transform = .identity
                self.customTabBarView.alpha = 1
            }
        }, completion: nil)
    }
}

// MARK: - Setup UI
private extension MainTabBarController {
    
    func setCustomView() {
        let view = CustomTabBar(tabState: self.tabBarState)
        let viewWrapper = UIHostingController(rootView: view)
        
        customTabBarView = viewWrapper.view
        self.view.addSubview(customTabBarView)
        customTabBarView.backgroundColor = .white
        customTabBarView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(24.flexible())
            $0.horizontalEdges.equalToSuperview().inset(16.flexible())
            $0.height.equalTo(50.flexible())
            $0.centerX.equalToSuperview()
        }
        customTabBarView.layer.cornerRadius = 32.flexible()
    }
}
