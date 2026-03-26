//
//  SearchViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 25.03.2026.
//

import Foundation
import Combine
import Alamofire

struct SearchRouter {
    
}

final class SearchViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published private(set) var result: [Book] = []
    @Published private(set) var state = ViewState.idle
    @Published private(set) var error: NetworkError?
    
    private let networkService: NetworkProtocol
    private let router: SearchRouter
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        networkService: NetworkProtocol,
        router: SearchRouter
    ) {
        self.networkService = networkService
        self.router = router
    }
    
    func startObserve() {
        guard cancellables.isEmpty else { return }
        
        $searchText
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] text in
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self?.state = .idle
                } else {
                    self?.state = .loading
                }
            })
            .filter { $0.count >= 2 }
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                Task {
                    await self?.makeRequest(with: query)
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func makeRequest(with text: String) async {
        if Task.isCancelled { return }
        
        let request = Request(
            path: "",
            method: .get,
            parameters: [
                "q": "intitle:\(text)",
                "key": NetworkConstants.booksQueryKey,
                "maxResults": "15",
                "printType": "books",
                "orderBy": "newest"
            ]
        )
        
        do {
            let response: Books = try await networkService.executeWithCodable(request: request)
            
            if let books = response.books {
                self.result = books
                self.state = .success
            } else {
                self.result = []
                self.state = .empty
            }
        } catch {
            self.error = error as? NetworkError
            print(error.localizedDescription)
            self.state = .failed
        }
    }
}
