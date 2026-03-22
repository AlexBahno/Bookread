//
//  Services.swift
//  Bookread
//
//  Created by Alexandr Bahno on 06.03.2026.
//

import Foundation

final class Services {
    
    lazy var firebaseService: FirebaseServiceProtocol = FirebaseService()
    lazy var sessionService: any SessionServiceProtocol = SessionService.shared
}
