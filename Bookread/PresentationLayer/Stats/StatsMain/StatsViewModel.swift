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
    
    // Дані для календаря (Ключ - початок дня)
    @Published var monthlyStats: [Date: DailyReadingStatistic] = [:]
    // Локальний кеш книг користувача для швидкого доступу до обкладинок та назв
    @Published var userBooks: [String: UserBook] = [:]
    @Published var isLoading = false
    
    private let statsService: StatisticsServiceProtocol
    private let bookService: BookServiceProtocol
    
    init(services: Services) {
        self.statsService = services.statsSetvice
        self.bookService = services.bookService
    }
    
    @MainActor
    func loadStatisticsForCurrentMonth() {
        let (startDate, endDate) = getCurrentMonthDateRange()
        isLoading = true
        
        Task {
            do {
                // 1. Запускаємо обидва мережеві запити ПАРАЛЕЛЬНО
                async let fetchedStats = statsService.fetchMonthlyStatistics(from: startDate, to: endDate)
                async let fetchedBooksArray = bookService.fetchUserBooks() // Завантажуємо масив книг
                
                // 2. Чекаємо, поки ОБИДВА запити завершаться
                let (stats, booksArray) = try await (fetchedStats, fetchedBooksArray)
                
                // 3. Перетворюємо масив [UserBook] у словник [String: UserBook]
                // де ключем є ID книги. Це потрібно для миттєвого пошуку O(1)
                var booksDictionary: [String: UserBook] = [:]
                for book in booksArray {
                    booksDictionary[book.id] = book
                }
                
                // 4. Оновлюємо UI на головному потоці
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
            through: lastWeek.end,
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
        // Початок поточного місяця
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        let startDate = calendar.date(from: components)!
        
        // Кінець місяця
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        
        return (startDate, endDate)
    }
}
