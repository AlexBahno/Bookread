//
//  HistoryReadingCell.swift
//  Bookread
//
//  Created by Alexandr Bahno on 22.03.2026.
//

import SwiftUI

struct HistoryReadingCell: View {
    
    var body: some View {
        content
            .padding(16.flexible())
            .background {
                RoundedRectangle(cornerRadius: 16.flexible())
                    .fill(.white)
                    .shadow(radius: 2.flexible())
            }
    }
    
    var content: some View {
        HStack(spacing: 16.flexible()) {
            ZStack {
                Image(systemName: "clock")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.primary2D5F5D)
                    .frame(width: 24.flexible(), height: 24.flexible())
                
                Circle()
                    .fill(.primary2D5F5D.opacity(0.2))
                    .frame(width: 48.flexible(), height: 48.flexible())
            }
            
            VStack(alignment: .leading, spacing: 16.flexible()) {
                HStack(alignment: .top) {
                    Text("Title of the book Title of the book Title of the book")
                        .interRegular(size: 20.flexible())
                        .fontWeight(.medium)
                        .foregroundStyle(.text1A1A1A)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text("Just now")
                        .interRegular(size: 14.flexible())
                        .foregroundStyle(.gray9E9E9E)
                        .offset(y: -4.flexible())
                }
                
                HStack(spacing: 8.flexible()) {
                    HStackWithImage("clock", text: "45 min")
                    HStackWithImage("book", text: "32 pages")
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
}
