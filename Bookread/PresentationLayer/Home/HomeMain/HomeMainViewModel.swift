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

@MainActor
final class HomeMainViewModel: ObservableObject {
    
    @Published private(set) var books: [UserBook] = []
    private let firebaseService: FirebaseServiceProtocol
    private let router: HomeMainRouter
    
    private var listenerTask: Task<Void, Never>?
    
    init(
        firebaseService: FirebaseServiceProtocol,
        router: HomeMainRouter
    ) {
        self.firebaseService = firebaseService
        self.router = router
    }
    
    func startListening() {
        listenerTask = Task {
            do {
                for try await books in firebaseService.userBooksStream() {
                    self.books = books
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func stopListening() {
        listenerTask?.cancel()
        listenerTask = nil
    }
}
