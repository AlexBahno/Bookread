//
//  NetworkConstants.swift
//  Bookread
//
//  Created by Alexandr Bahno on 24.03.2026.
//

import Foundation

enum NetworkConstants {
    
    static let booksBaseUrl = "https://www.googleapis.com/books/v1/volumes"
    static let booksQueryKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GoogleBooksAPIKey") as? String,
              !key.isEmpty else {
            fatalError("GoogleBooksAPIKey is missing. Create Secrets.xcconfig (see Secrets.example.xcconfig).")
        }
        return key
    }()
}
