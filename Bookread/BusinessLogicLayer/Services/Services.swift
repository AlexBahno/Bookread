//
//  Services.swift
//  Bookread
//
//  Created by Alexandr Bahno on 06.03.2026.
//

import Foundation

final class Services {
    
    lazy var sessionService: SessionServiceProtocol = SessionService.shared
    lazy var networkService: NetworkProtocol = NetworkService()
    
    // Firebase services
    lazy var profileImageService: FB_ProfileImageServiceProtocol = FB_ProfileImageService()
    lazy var authService: FB_AuthServiceProtocol = FB_AuthService()
    lazy var statsSetvice: FB_StatisticsServiceProtocol = FB_StatisticsService()
    lazy var bookService: FB_BookServiceProtocol = FB_BookService()
    lazy var socialService: FB_SocialServiceProtocol = FB_SocialService()
    lazy var feedService: FB_FeedServiceProtocol = FB_FeedService()
    lazy var userService: FB_UserServiceProtocol = FB_UserService()
    lazy var readingSessionService: FB_ReadingSessionServiceProtocol = FB_ReadingSessionService()
}
