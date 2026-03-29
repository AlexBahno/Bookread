//
//  HomeMainViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29.03.2026.
//

import Foundation
import Combine

struct HomeMainRouter {
    
}

final class HomeMainViewModel: ObservableObject {
    
    private let router: HomeMainRouter
    
    init(router: HomeMainRouter) {
        self.router = router
    }
}
