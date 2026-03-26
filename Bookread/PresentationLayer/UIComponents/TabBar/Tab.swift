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
    case addBook = 2
    case stats = 3
    case profile = 4
    
    var id: Self { self }

    var title: String {
        switch self {
        case .home: "Home"
        case .explore: "Explore"
        case .addBook: ""
        case .stats: "Stats"
        case .profile: "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .home: "house"
        case .explore: "safari"
        case .addBook: "plus.circle.fill"
        case .stats: "chart.bar.xaxis"
        case .profile: "person"
        }
    }
}
