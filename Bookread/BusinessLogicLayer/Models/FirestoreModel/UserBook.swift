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

struct UserBook: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var author: String
    var coverImageUrl: String?
    var startPage: Int
    var progress: Int
    var totalPages: Int
    var status: ReadingStatus
    var lastReadAt: Date?
    
    var totalReadingSeconds: Int = 0
    
    init(id: String, title: String, author: String, coverImageUrl: String?, startPage: Int, progress: Int, totalPages: Int, status: ReadingStatus, lastReadAt: Date? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.coverImageUrl = coverImageUrl
        self.startPage = startPage
        self.progress = progress
        self.totalPages = totalPages
        self.status = status
        self.lastReadAt = lastReadAt
    }
    
    init() {
        self.id = UUID().uuidString
        self.title = ""
        self.author = ""
        self.coverImageUrl = nil
        self.startPage = 0
        self.progress = 0
        self.totalPages = 0
        self.status = .none
        self.lastReadAt = .now
    }
    
    var estimatedTimeToFinish: String {
        guard totalReadingSeconds > 0, progress > 0 else {
            return "Read more for estimate"
        }
        
        let pagesRemaining = totalPages - progress
        guard pagesRemaining > 0 else { return formattedTotalReadTime}
        
        let speed = Double(progress) / Double(totalReadingSeconds)
        let secondsRemaining = Double(pagesRemaining) / speed
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        
        return "\(formatter.string(from: secondsRemaining) ?? "Unknown") left"
    }
    
    private var formattedTotalReadTime: String {
        var res = totalReadingSeconds
        if res < 60 {
            res = 60
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        
        return "Finished in \(formatter.string(from: Double(res)) ?? "N/A")"
    }
    
    var imgURL: URL? {
        if let coverImageUrl {
            return URL(string: coverImageUrl)
        }
        return nil
    }
    
    var percentProgress: Double {
        totalPages == 0 ? 0 : Double(progress) / Double(totalPages)
    }
    
    var isFinished: Bool {
        status == .finished && totalPages - progress == 0
    }
}
