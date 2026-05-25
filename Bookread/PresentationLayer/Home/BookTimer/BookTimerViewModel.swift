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
    @Published var startTime = Date()
    @Published var endPage = 0
    @Published var timer: Timer?
    
    @Published var bookSessions: [ReadingSession] = []
    @Published var book: UserBook
    
    private var liveBookTask: Task<Void, Never>?
    private var sessionListenerTask: Task<Void, Never>?
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
                book.progress = book.startPage
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
    
    /// Starts fetching the history for just this book
    func startListeningToSessions() {
        sessionListenerTask = Task {
            do {
                for try await sessions in firebaseService.bookSessionsStream(for: book.id) {
                    self.bookSessions = sessions
                }
            } catch {
                print("Error fetching book sessions: \(error)")
            }
        }
    }
    
    func stopListening() {
        sessionListenerTask?.cancel()
        sessionListenerTask = nil
    }
    
    func startLiveSync() {
        liveBookTask = Task {
            do {
                // Sit and wait for updates to this one document
                for try await updatedBook in firebaseService.bookStream(bookId: book.id) {
                    if let updatedBook {
                        self.book = updatedBook
                    }
                }
            } catch {
                print("Error syncing book: \(error)")
            }
        }
    }
    
    func stopLiveSync() {
        liveBookTask?.cancel()
        liveBookTask = nil
    }
}

// MARK: Timer
extension BookTimerViewModel {
    
    func startReading() {
        currentState = .reading
        startTime = .now
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
            // 1. Create the session object
            let newSession = ReadingSession(
                bookId: book.id,
                bookTitle: book.title,
                bookAuthor: book.author,
                bookCoverImageUrl: book.coverImageUrl,
                startTime: startTime,
                endTime: startTime.addingTimeInterval(elapsedTime),
                startPage: book.progress,
                endPage: endPage,
                bookTotalPages: book.totalPages
            )
            
            try await firebaseService.logReadingSession(
                session: newSession,
                newTotalProgress: endPage,
                isFinished: endPage >= book.totalPages
            )
            
            elapsedTime = 0
        }
        
        currentState = .notStarted
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
