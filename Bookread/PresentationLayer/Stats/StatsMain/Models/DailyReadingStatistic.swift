//
//  DailyReadingStatistic.swift
//  Bookread
//
//  Created by Alexandr Bahno on 27/05/2026.
//

import Foundation

/// Модель, яка представляє статистику за один конкретний день
struct DailyReadingStatistic {
    let date: Date
    /// Словник, де ключ — це ID книги, а значення — загальний час читання в секундах
    var bookDurations: [String: TimeInterval] = [:]
    
    /// Повертає ID книги, яку читали найдовше в цей день (для картинки в календарі)
    var topBookId: String? {
        bookDurations.max { $0.value < $1.value }?.key
    }
}
