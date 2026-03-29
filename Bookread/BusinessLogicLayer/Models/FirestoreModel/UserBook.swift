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
    @DocumentID var id: String?
    let title: String
    let author: String
    let coverImageUrl: String?
    var startPage: Int
    var progress: Int
    var totalPages: Int
    var status: ReadingStatus
    var lastReadAt: Date?
    
    
    var imgURL: URL? {
        if let coverImageUrl {
            return URL(string: coverImageUrl)
        }
        return nil
    }
    
    var percentProgress: Double {
        Double(progress) / Double(totalPages)
    }
}
