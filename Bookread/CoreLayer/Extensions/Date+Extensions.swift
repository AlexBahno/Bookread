//
//  Date+Extensions.swift
//  Stacklet-Time-Guard
//
//  Created by Andrei Secrieru on 16.12.2024.
//

import Foundation
import SwiftUI

typealias Year = Int
typealias Month = Int
typealias Day = Int


extension Date {
    
    func longFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.M.yyyy"
        return dateFormatter.string(from: self)
    }
    
    func toMonthAndYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func toMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    func toDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    
    func toTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var longDateFormat: String {
           let dateFormatter = DateFormatter()
           if Calendar.current.isDateInToday(self) {
               dateFormatter.dateFormat = "d MMMM" // "Monday, 5 January"
               return "Today, \(dateFormatter.string(from: self))"
           } else {
               dateFormatter.dateFormat = "EEEE, d MMMM" // "Monday, 5 January"
               return dateFormatter.string(from: self)
           }
       }
}

extension Month {
    
    /// Show month as string according to format
    func toString(with format: StringFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        var components = DateComponents()
        components.year = 2000
        components.month = self
        components.day = 1
        
        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            switch format {
            case .long:
                dateFormatter.dateFormat = "MMMM"
            }
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    /// Switch to next or previous month accordingly to year
    mutating func `switch`(to action: UpdateAction, in year: Binding<Year>) {
        switch action {
        case .next:
            if self == 12 {
                year.wrappedValue += 1
            }
            self = self == 12 ? 1 : self + 1
            
        case .previous:
            if self == 1 {
                year.wrappedValue -= 1
            }
            self = self == 1 ? 12 : self - 1
        }
    }
    
    /// Get all month days from given year
    func monthDays(in year: Year = Calendar.current.component(.year, from: Date())) -> [Day] {
        let calendar = Calendar.current
        
        // Create the start of the specified month
        var components = DateComponents()
        components.year = year
        components.month = self
        
        if let monthStart = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: monthStart) {
            return Array(range)
        }
        return []
    }
    
    enum UpdateAction {
        case next
        case previous
    }
    
    enum StringFormat {
        case long
    }
}

extension Date {
    func formattedWithSuffix() -> String {
            let calendar = Calendar.current
            if calendar.isDateInToday(self) {
                return "Today"
            }

            let day = calendar.component(.day, from: self)
            let year = calendar.component(.year, from: self)

            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            let month = monthFormatter.string(from: self)

            let suffix: String
            switch day {
            case 11, 12, 13:
                suffix = "th"
            default:
                switch day % 10 {
                case 1: suffix = "st"
                case 2: suffix = "nd"
                case 3: suffix = "rd"
                default: suffix = "th"
                }
            }

            return "\(day)\(suffix) \(month), \(year)"
        }
}

extension Date {
    func toFormatted() -> String { // "01.04.2025, 10:45"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    func toFormattedDate() -> String { // "01.04.2025"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}
