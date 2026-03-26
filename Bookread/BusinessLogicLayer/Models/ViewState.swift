//
//  CitiesListViewState.swift
//  CityWeather
//
//  Created by Alexandr Bahno on 15.03.2026.
//

import Foundation

// MARK: - View states
enum ViewState: Equatable {
    case idle
    case empty
    case loading
    case failed
    case success
}
