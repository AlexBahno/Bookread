//
//  Services.swift
//  Bookread
//
//  Created by Alexandr Bahno on 06.03.2026.
//

import Foundation

final class Services {
    
    lazy var firebaseService: FirebaseServiceProtocol = FirebaseService()
    lazy var profileImageService: ProfileImageServiceProtocol = ProfileImageService()
    lazy var authService: AuthServiceProtocol = AuthService()
    
    lazy var sessionService: SessionServiceProtocol = SessionService.shared
    lazy var networkService: NetworkProtocol = NetworkService()
    lazy var statsSetvice: StatisticsServiceProtocol = StatisticsService()
    lazy var bookService: BookServiceProtocol = BookService()
}
