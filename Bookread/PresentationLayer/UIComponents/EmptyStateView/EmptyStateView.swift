//
//  EmptyStateView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 26.03.2026.
//

import SwiftUI

struct EmptyStateView: View {
    
    let image: String
    let title: String
    
    var body: some View {
        VStack(spacing: 16.flexible()) {
            Image(systemName: image)
                .resizable()
                .scaledToFill()
                .font(.system(size: 32.flexible()))
                .frame(width: 32.flexible(), height: 32.flexible())
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.text1A1A1A)
                .multilineTextAlignment(.center)
        }
    }
}
