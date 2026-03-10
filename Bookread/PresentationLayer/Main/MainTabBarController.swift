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

final class MainTabBarController: UITabBarController {
    
    private let tabBarState = TabBarState()
    private var customTabBarView = UIView()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = true
        setCustomView()
        
        tabBarState.$selectedTab
            .sink { tab in
                self.selectedIndex = tab.rawValue
            }
            .store(in: &cancellables)
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
