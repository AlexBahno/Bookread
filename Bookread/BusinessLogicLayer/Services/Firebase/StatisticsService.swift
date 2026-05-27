//
//  StatisticsService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 27/05/2026.
//

import FirebaseFirestore
import FirebaseAuth

protocol StatisticsServiceProtocol {
    func fetchMonthlyStatistics(from startDate: Date, to endDate: Date) async throws -> [Date: DailyReadingStatistic]
}

final class StatisticsService: StatisticsServiceProtocol {
    
    private let db = Firestore.firestore()
    
    /// Завантажує та агрегує сесії читання за вказаний період
    /// - Parameters:
    ///   - startDate: Початок місяця
    ///   - endDate: Кінець місяця
    /// - Returns: Словник [Дата початку дня : Статистика за цей день]
    func fetchMonthlyStatistics(from startDate: Date, to endDate: Date) async throws -> [Date: DailyReadingStatistic] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw URLError(.userAuthenticationRequired)
        }
        
        // 1. Формуємо запит до підколекції readingSessions
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("readingSessions")
            .whereField("startTime", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("startTime", isLessThanOrEqualTo: Timestamp(date: endDate))
            .getDocuments()
        
        var dailyStats: [Date: DailyReadingStatistic] = [:]
        let calendar = Calendar.current
        
        // 2. Парсимо та агрегуємо дані
        for document in snapshot.documents {
            let data = document.data()
            
            // Дістаємо startTime та endTime замість duration
            guard let bookId = data["bookId"] as? String,
                  let startTimestamp = data["startTime"] as? Timestamp,
                  let endTimestamp = data["endTime"] as? Timestamp else {
                // Якщо endTime немає (наприклад, сесія ще не завершена), ми її ігноруємо для статистики
                continue
            }
            
            // Конвертуємо Firebase Timestamp у Swift Date
            let sessionStartDate = startTimestamp.dateValue()
            let sessionEndDate = endTimestamp.dateValue()
            
            // ВИРАХОВУЄМО ТРИВАЛІСТЬ ДИНАМІЧНО:
            // timeIntervalSince повертає різницю у секундах (TimeInterval)
            let duration = sessionEndDate.timeIntervalSince(sessionStartDate)
            
            // Нормалізуємо дату до 00:00:00, щоб всі сесії одного дня мали однаковий ключ
            let startOfDay = calendar.startOfDay(for: sessionStartDate)
            
            // 3. Додаємо час до відповідного дня та книги
            if dailyStats[startOfDay] == nil {
                dailyStats[startOfDay] = DailyReadingStatistic(date: startOfDay)
            }
            
            let currentBookDuration = dailyStats[startOfDay]?.bookDurations[bookId] ?? 0
            dailyStats[startOfDay]?.bookDurations[bookId] = currentBookDuration + duration
        }
        
        return dailyStats
    }
}
