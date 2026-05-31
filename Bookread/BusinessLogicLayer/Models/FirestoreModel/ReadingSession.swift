//
//  ReadingSession.swift
//  Bookread
//
//  Created by Alexandr Bahno on 01.04.2026.
//

import Foundation
import FirebaseFirestore

struct ReadingSession: Identifiable, Codable {
    @DocumentID var id: String?
    
    let bookId: String
    let bookTitle: String
    let bookAuthor: String?
    let bookCoverImageUrl: String?
    
    let startTime: Date
    let endTime: Date
    
    let startPage: Int
    let endPage: Int
    
    let bookTotalPages: Int
    
    let userId: String
    
    var pagesRead: Int {
        return max(0, endPage - startPage)
    }
    
    var durationInSeconds: Int {
        let seconds = endTime.timeIntervalSince(startTime)
        return Int(seconds)
    }
    
    var formattedTime: String {
        let elapsedTime = endTime.timeIntervalSince(startTime)
        
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        
        if hours > 0 {
            return String(format: "%dh %2dm", hours, minutes)
        } else {
            return String(format: "%2d minutes", minutes)
        }
    }
    
    var dateString: String {
         let formatter = DateFormatter()
         if Calendar.current.isDateInToday(startTime) {
             return "Today"
         } else if Calendar.current.isDateInYesterday(startTime) {
             return "Yesterday"
         } else {
             formatter.dateFormat = "MMM d"
             return formatter.string(from: startTime)
         }
     }
    
    var sessionPercentage: Double {
        guard bookTotalPages > 0 else { return 0.0 }
        
        let rawPercentage = (Double(pagesRead) / Double(bookTotalPages))
        return rawPercentage
    }
    
    var totalPercentage: Double {
        guard bookTotalPages > 0 else { return 0.0 }
        
        let rawPercentage = (Double(endPage) / Double(bookTotalPages))
        return rawPercentage
    }
    
    var imgURL: URL? {
        if let bookCoverImageUrl {
            return URL(string: bookCoverImageUrl)
        }
        return nil
    }
}

struct SpeedChange {
    let isImprovement: Bool
    let percentChange: Double
    
    var description: String {
        let direction = isImprovement ? "faster" : "slower"
        return "\(Int(percentChange))% \(direction)"
    }
}
