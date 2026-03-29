//
//  CustomProgressView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29.03.2026.
//

import SwiftUI

struct CustomProgressView: View {
    
    let currentPage: Int
    let totalPages: Int
    let progress: Double
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Page \(currentPage) of \(totalPages)")
                    .interRegular(size: 16.flexible())
                    .fontWeight(.semibold)
                    .foregroundColor(.text1A1A1A)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .interRegular(size: 16.flexible())
                    .fontWeight(.semibold)
                    .foregroundColor(.accentC17767)
            }
            .padding(.bottom, 8.flexible())
            
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
                        .frame(width: geometry.size.width * progress, height: 8.flexible())
                }
            }
            .frame(height: 8.flexible())
        }
        .padding(.horizontal, 16.flexible())
        .padding(.top, 20.flexible())
        .padding(.bottom, 16.flexible())
        .background {
            RoundedRectangle(cornerRadius: 16.flexible())
                .fill(.white)
                .shadow(radius: 2.flexible())
        }
    }
}
