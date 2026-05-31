//
//  StatsViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 27/05/2026.
//

import Combine
import Foundation

final class StatsViewModel: ObservableObject {
    
    let calendar = Calendar.current
    @Published var displayedMonth = Date()
    @Published var selectedDate: Date = .now
    
    @Published var monthlyStats: [Date: DailyReadingStatistic] = [:]
    @Published var userBooks: [String: UserBook] = [:]
    @Published var isLoading = false
    
    private let statsService: StatisticsServiceProtocol
    private let bookService: BookServiceProtocol
    private let sessionService: SessionServiceProtocol
    
    init(services: Services) {
        self.statsService = services.statsSetvice
        self.bookService = services.bookService
        self.sessionService = services.sessionService
    }
    
    @MainActor
    func loadStatisticsForCurrentMonth() {
        guard let userID = sessionService.currentUser?.id else { return }
        let (startDate, endDate) = getCurrentMonthDateRange()
        isLoading = true
        
        Task {
            do {
                async let fetchedStats = statsService.fetchMonthlyStatistics(from: startDate, to: endDate)
                async let fetchedBooksArray = bookService.fetchUserBooks(userID: userID)
                
                let (stats, booksArray) = try await (fetchedStats, fetchedBooksArray)
                
                var booksDictionary: [String: UserBook] = [:]
                for book in booksArray {
                    booksDictionary[book.id] = book
                }
                
                self.userBooks = booksDictionary
                self.monthlyStats = stats
                
            } catch {
                print("Помилка завантаження даних для статистики: \(error.localizedDescription)")
            }
            
            self.isLoading = false
        }
    }
    
    // Допоміжна функція для UI календаря:
    @MainActor
    func getTopBookImageUrl(for date: Date) -> String? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let stat = monthlyStats[startOfDay],
              let topBookId = stat.topBookId,
              let book = userBooks[topBookId] else {
            return nil
        }
        return book.coverImageUrl
    }
    
    func generateMonthGrid() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else { return [] }
        return stride(
            from: firstWeek.start,
            to: lastWeek.end,
            by: 86400
        ).map { $0 }
    }
    
    func getBookForTheDay() -> [UserBook : TimeInterval] {
        guard let statForDay = monthlyStats[calendar.startOfDay(for: selectedDate)] else {
            return [:]
        }
        var result: [UserBook: TimeInterval] = [:]
        for (bookId, duration) in statForDay.bookDurations {
            if let book = userBooks[bookId] {
                result[book] = duration
            }
        }
        return result
    }
    
    private func getCurrentMonthDateRange() -> (Date, Date) {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        let startDate = calendar.date(from: components)!
        
        let endDate = calendar.date(byAdding: DateComponents(month: 1), to: startDate)!
        
        return (startDate, endDate)
    }
}
