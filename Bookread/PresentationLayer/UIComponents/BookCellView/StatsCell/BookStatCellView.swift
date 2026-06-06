//
//  BookStatCellView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 27/05/2026.
//

import SwiftUI

struct BookStatCellView: View {
    
    let book: UserBook
    let duration: TimeInterval
    
    var formattedTime: String {
        if duration < 60 {
            return "1 minute"
        }
        
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes")"
        }
    }
    
    var body: some View {
        container
            .padding(.horizontal, 16.flexible())
            .padding(.vertical, 12.flexible())
            .background {
                RoundedRectangle(cornerRadius: 16.flexible())
                    .fill(.white)
                    .shadow(radius: 2.flexible())
            }
    }
    
    var container: some View {
        HStack(spacing: 8.flexible()) {
            bookCoverImage
                .frame(width: 128.flexible()*0.8, height: 169.flexible()*0.8)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8.flexible()))
            
            VStack(alignment: .leading) {
                Text(book.title)
                    .interRegular(size: 18.flexible())
                    .foregroundStyle(.text1A1A1A)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 8.flexible())
                
                Text(book.author)
                    .interRegular(size: 16.flexible())
                    .foregroundStyle(.gray666666)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                HStack(spacing: 8.flexible()) {
                    HStackWithImage("clock", text: formattedTime)
//                    HStackWithImage("book", text: "\(session.pagesRead)")
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    var bookCoverImage: some View {
        AsyncImage(url: book.imgURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .fill(.gray9E9E9E.opacity(0.8))
                .overlay(alignment: .center) {
                    VStack(spacing: 4.flexible()) {
                        Text(book.title)
                            .interRegular(size: 8.flexible())
                            .foregroundStyle(.text1A1A1A)
                            .multilineTextAlignment(.center)
                        
                        Text(book.author)
                            .interRegular(size: 8.flexible())
                            .foregroundStyle(.text1A1A1A)
                            .multilineTextAlignment(.center)
                    }
                    .padding(4.flexible())
                }
        }
    }
    
    func HStackWithImage(_ image: String, text: String) -> some View {
        HStack(spacing: 4.flexible()) {
            Image(systemName: image)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.gray9E9E9E)
                .frame(width: 14.flexible(), height: 14.flexible())
            
            Text(text)
                .interRegular(size: 14.flexible())
                .foregroundStyle(.gray9E9E9E)
        }
    }
}
