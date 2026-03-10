//
//  Tab.swift
//  Bookread
//
//  Created by Alexandr Bahno on 10.03.2026.
//

import Foundation

enum Tab: Int, Identifiable, CaseIterable, Hashable {
    case home = 0
    case explore = 1
    case stats = 2
    case profile = 3
    
    var id: Self { self }

    var title: String {
        switch self {
        case .home: "Home"
        case .explore: "Explore"
        case .stats: "Stats"
        case .profile: "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .home: "house"
        case .explore: "safari"
        case .stats: "chart.bar.xaxis"
        case .profile: "person"
        }
    }
}
