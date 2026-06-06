//
//  AddCustomBookViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 06/06/2026.
//

import Combine
import _PhotosUI_SwiftUI

struct AddCustomBookRouter {
    let openBook: (UserBook) -> Void
}

@MainActor
final class AddCustomBookViewModel: ObservableObject {
    
    @Published var book: UserBook = .init()
    @Published var bookCover: UIImage? = nil
    @Published var isLoading = false
    
    @Published var selectedPhoto: PhotosPickerItem? {
        didSet {
            Task {
                await loadPhoto()
            }
        }
    }
    
    private let storageService: FB_StorageServiceProtocol
    private let bookService: FB_BookServiceProtocol
    
    private let router: AddCustomBookRouter
    
    var isFormValid: Bool {
        !book.title.isEmpty && !book.author.isEmpty
    }
    
    init(services: Services, router: AddCustomBookRouter) {
        self.storageService = services.storageService
        self.bookService = services.bookService
        
        self.router = router
    }
    
    private func loadPhoto() async {
        guard let selectedPhoto = selectedPhoto else { return }
        
        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.bookCover = image
            }
        } catch {
            print("Failed to load photo: \(error)")
        }
    }
    
    func loadBook() async {
        self.isLoading = true
        do {
            if let image = bookCover {
                let newUrl = try await self.storageService
                    .uploadOwnBookCover(bookID: book.id, image)
                
                self.book.coverImageUrl = newUrl
            }
            try await bookService.addBook(book: book)
        } catch {
            print("Failed to load photo: \(error)")
        }
        self.isLoading = false
        self.router.openBook(book)
    }
}
