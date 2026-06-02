//
//  HistoryReadingCell.swift
//  Bookread
//
//  Created by Alexandr Bahno on 22.03.2026.
//

import SwiftUI

struct HistoryReadingCell: View {
    
    let session: ReadingSession
    
    var body: some View {
        VStack(spacing: .zero) {
            infoStack
                .padding(16.flexible())
                .background {
                    Rectangle()
                        .fill(.white)
                        .cornerRadius(16.flexible(), corners: [.topLeft, .topRight])
                        .shadow(radius: 2.flexible())
                }
            
            Divider()
                .foregroundStyle(.gray666666)
                .frame(height: 1.flexible())
            
            actionsStack
                .padding(.horizontal, 8.flexible())
                .padding(.vertical, 4.flexible())
                .background {
                    Rectangle()
                        .fill(.white)
                        .cornerRadius(16.flexible(), corners: [.bottomLeft, .bottomRight])
                        .shadow(radius: 2.flexible())
                }
        }
    }
    
    var infoStack: some View {
        HStack(spacing: 16.flexible()) {
            bookCoverImage
                .frame(width: 64.flexible(), height: 84.5.flexible())
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8.flexible()))
            
            VStack(alignment: .leading, spacing: 16.flexible()) {
                HStack(alignment: .top) {
                    Text(session.bookTitle)
                        .interRegular(size: 20.flexible())
                        .fontWeight(.medium)
                        .foregroundStyle(.text1A1A1A)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(session.dateString)
                        .interRegular(size: 14.flexible())
                        .foregroundStyle(.gray9E9E9E)
                        .offset(y: -4.flexible())
                }
                
                HStack(spacing: 8.flexible()) {
                    HStackWithImage("clock", text: session.formattedTime)
                    HStackWithImage("book", text: "\(session.pagesRead)")
                }
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
    
    @ViewBuilder
    var bookCoverImage: some View {
        if let imgURL = session.imgURL {
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
                        Text(session.bookTitle)
                            .interRegular(size: 8.flexible())
                            .foregroundStyle(.text1A1A1A)
                            .multilineTextAlignment(.center)
                        
                        Text(session.bookAuthor ?? "N/A")
                            .interRegular(size: 8.flexible())
                            .foregroundStyle(.text1A1A1A)
                            .multilineTextAlignment(.center)
                    }
                    .padding(4.flexible())
                }
        }
    }
    
    var actionsStack: some View {
        HStack(spacing: .zero) {
            HStack(spacing: 6.flexible()) {
                Image(systemName: "heart")
                    .font(.system(size: 20.flexible()))
                    .foregroundColor(.primary2D5F5D)
                
                Text("\(session.likesCount)")
                    .interRegular(size: 18.flexible())
                    .foregroundColor(.text1A1A1A)
            }
            
            Spacer()
        }
    }
}
