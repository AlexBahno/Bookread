//
//  Book.swift
//  Bookread
//
//  Created by Alexandr Bahno on 24.03.2026.
//

import Foundation

struct Books: Codable {
    let totalItems: Int
    let books: [Book]?
    
    enum CodingKeys: String, CodingKey {
        case books = "items"
        case totalItems
    }
}

// MARK: - Book
struct Book: Identifiable, Codable {
    let id: String
    let bookInfo: BookInfo
    
    enum CodingKeys: String, CodingKey {
        case id
        case bookInfo = "volumeInfo"
    }
}

// MARK: - BookInfo
struct BookInfo: Codable {
    let title: String
    let publishedDate: String?
    let subtitle: String?
    let authors: [String]?
    let publisher, description: String?
    let industryIdentifiers: [IndustryIdentifier]?
    let pageCount: Int?
    let categories: [String]?
    let imageLinks: ImageLinks?
    let language: String?
}

// MARK: - ImageLinks
struct ImageLinks: Codable {
    let smallThumbnail, thumbnail: String
}

// MARK: - IndustryIdentifier
struct IndustryIdentifier: Codable {
    let type, identifier: String
}
