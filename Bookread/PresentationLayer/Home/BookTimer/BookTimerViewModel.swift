//
//  BookTimerViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29.03.2026.
//

import Foundation
import Combine

final class BookTimerViewModel: ObservableObject {
    
    enum ReadingState {
        case notStarted
        case reading
        case paused
    }
    
    @Published var currentState: ReadingState = .notStarted
    @Published var elapsedTime: TimeInterval = 0
    @Published var timer: Timer?
    @Published var book: UserBook
    
    private let firebaseService: FirebaseServiceProtocol
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var statusText: String {
        switch currentState {
        case .notStarted:
            return "Ready to start"
        case .reading:
            return "Reading..."
        case .paused:
            return "Paused"
        }
    }
    
    init(
        book: UserBook,
        firebaseService: FirebaseServiceProtocol
    ) {
        self.book = book
        self.firebaseService = firebaseService
    }
}

// MARK: Network
extension BookTimerViewModel {
    
    func addBookToFirebase() {
        Task {
            do {
                book.status = .reading
                try await firebaseService.addBook(book: book)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchBook() async {
        do {
            if let book = try await firebaseService.getUserBook(bookId: book.id) {
                self.book = book
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: Timer
extension BookTimerViewModel {
    
    func startReading() {
        currentState = .reading
        startTimer()
    }
    
    func pauseReading() {
        currentState = .paused
        stopTimer()
    }
    
    func continueReading() {
        currentState = .reading
        startTimer()
    }
    
    func finishReading() {
        stopTimer()
        
        Task {
            try await firebaseService.updateBook(
                bookID: book.id, updatedData: [
                    "progress": book.progress,
                    "lastReadAt": Date()
                ]
            )
        }
        
        currentState = .notStarted
        elapsedTime = 0
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
