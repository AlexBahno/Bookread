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
                
                HStack(spacing: 4.flexible()) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4.flexible())
                                .fill(.secondaryE8DFD0)
                                .frame(height: 8.flexible())
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: 4.flexible())
                                .fill(.accentC17767)
                                .frame(
                                    width: geometry.size.width * book.percentProgress,
                                    height: 8.flexible()
                                )
                        }
                    }
                    .frame(height: 8.flexible())
                    
                    Text("\(Int(book.percentProgress * 100))%")
                        .interRegular(size: 14.flexible())
                        .foregroundStyle(.gray666666)
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
}
