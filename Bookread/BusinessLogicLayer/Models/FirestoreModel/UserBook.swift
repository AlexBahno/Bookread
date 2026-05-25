//
//  UserBook.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29.03.2026.
//

import Foundation
import FirebaseFirestore

enum ReadingStatus: String, Codable {
    case none
    case toRead = "to-read"
    case reading = "reading"
    case finished = "finished"
}

struct UserBook: Identifiable, Codable {
    var id: String
    let title: String
    let author: String
    let coverImageUrl: String?
    var startPage: Int
    var progress: Int
    var totalPages: Int
    var status: ReadingStatus
    var lastReadAt: Date?
    
    var totalReadingSeconds: Int = 0
    
    // 2. THE MATH (Moved here from the ViewModel)
    var estimatedTimeToFinish: String {
        guard totalReadingSeconds > 0, progress > 0 else {
            return "Read more for estimate"
        }
        
        let pagesRemaining = totalPages - progress
        guard pagesRemaining > 0 else { return formattedTotalReadTime}
        
        // Speed is now Pages Per Second
        let speed = Double(progress) / Double(totalReadingSeconds)
        let secondsRemaining = Double(pagesRemaining) / speed
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute] // It will still display as Hours/Mins!
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        
        return "\(formatter.string(from: secondsRemaining) ?? "Unknown") left"
    }
    
    private var formattedTotalReadTime: String {
        //        guard totalReadingMinutes > 0 else { return "0 minutes" }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full // Spells out the words perfectly
        
        return "Finished in \(formatter.string(from: Double(totalReadingSeconds)) ?? "N/A")"
    }
    
    var imgURL: URL? {
        if let coverImageUrl {
            return URL(string: coverImageUrl)
        }
        return nil
    }
    
    var percentProgress: Double {
        Double(progress) / Double(totalPages)
    }
    
    var isFinished: Bool {
        totalPages - progress == 0
    }
}
