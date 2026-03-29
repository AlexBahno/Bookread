//
//  FoundedBookSheet.swift
//  Bookread
//
//  Created by Alexandr Bahno on 28.03.2026.
//

import SwiftUI

struct FoundedBookSheet: View {
    
    @Environment(\.dismiss) var dismiss
    
    let bookWrapper: Book
    
    var book: BookInfo {
        bookWrapper.bookInfo
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundFAFAF8)
    }
    
    var content: some View {
        VStack(spacing: .zero) {
            bookCoverImage
                .frame(width: 128.flexible()*1.5, height: 169.flexible()*1.5)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8.flexible()))
                .padding(.bottom, 24.flexible())
            
            Text(book.title)
                .interRegular(size: 26.flexible())
                .fontWeight(.medium)
                .foregroundStyle(.text1A1A1A)
            
            Spacer()
            
            AppStyleButton(text: "Read with Bookread", type: .withGreenBackground) {
                dismiss()
            }
        }
        .padding(.top, 32.flexible())
        .padding([.horizontal, .bottom], 16.flexible())
    }
    
    @ViewBuilder
    var bookCoverImage: some View {
        if let imgURL = book.imageLinks?.imgURL {
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
