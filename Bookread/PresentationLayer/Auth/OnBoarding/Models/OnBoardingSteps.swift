//
//  OnBoardingSteps.swift
//  Bookread
//
//  Created by Alexandr Bahno on 28.12.2025.
//

import Foundation

enum OnBoardingSteps: Int, CaseIterable, Identifiable {
    case track = 0
    case share = 1
    case discover = 2
    
    var id: Self { self }
    
    var image: String {
        switch self {
        case .track: "book.closed"
        case .share: "person.2"
        case .discover: "chart.line.uptrend.xyaxis"
        }
    }
    
    var title: String {
        switch self {
        case .track: "Track Your Reading"
        case .share: "Share Journey"
        case .discover: "Discover Insights"
        }
    }
    
    var description: String {
        switch self {
        case .track:
            "Keep a record of every book you read and organize your personal library"
        case .share:
            "Connect with fellow readers, share reviews, and discover what others are reading"
        case .discover:
            "Get personalized statistics about your reading habits and preferences"
        }
    }
    
    var nextStep: Self? {
        switch self {
        case .track: .share
        case .share: .discover
        case .discover: nil
        }
    }
}
