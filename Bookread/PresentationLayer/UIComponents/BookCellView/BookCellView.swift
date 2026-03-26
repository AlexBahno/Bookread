//
//  BookCellView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 26.03.2026.
//

import SwiftUI

struct BookCellView: View {
    
    let bookWrapper: Book
    
    var book: BookInfo {
        bookWrapper.bookInfo
    }
    
    var imgURL: URL? {
        let secureLink = book.imageLinks?.thumbnail
            .replacingOccurrences(
                of: "http://", with: "https://"
            )
        return URL(string: secureLink ?? "")
    }
    
    var pageCount: String {
        if let amount = book.pageCount {
            return "\(amount) pages"
        }
        return "N/a pages"
    }
    
    var body: some View {
        content
            .padding(.horizontal, 16.flexible())
            .padding(.vertical, 12.flexible())
            .background {
                RoundedRectangle(cornerRadius: 16.flexible())
                    .fill(.white)
                    .shadow(radius: 2.flexible())
            }
    }
    
    var content: some View {
        HStack(spacing: 8.flexible()) {
            bookCoverImage
                .frame(width: 64.flexible(), height: 84.5.flexible())
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8.flexible()))
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(book.title)
                    .interRegular(size: 18.flexible())
                    .foregroundStyle(.text1A1A1A)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 4.flexible())
                
                Text(book.authors?.first ?? "N/A")
                    .interRegular(size: 16.flexible())
                    .foregroundStyle(.text1A1A1A)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 2.flexible())
                
                Text(pageCount)
                    .interRegular(size: 14.flexible())
                    .foregroundStyle(.text1A1A1A)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var bookCoverImage: some View {
        if let imgURL {
            AsyncImage(url: imgURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(.gray9E9E9E.opacity(0.65))
                    .shimmer()
            }
        } else {
            Rectangle()
                .fill(.gray9E9E9E.opacity(0.8))
                .overlay(alignment: .center) {
                    VStack(spacing: 4.flexible()) {
                        Text(book.title)
                            .interRegular(size: 8.flexible())
                            .foregroundStyle(.text1A1A1A)
                            .multilineTextAlignment(.center)
                        
                        Text(book.authors?.first ?? "N/A")
                            .interRegular(size: 8.flexible())
                            .foregroundStyle(.text1A1A1A)
                            .multilineTextAlignment(.center)
                    }
                    .padding(4.flexible())
                }
        }
    }
}
