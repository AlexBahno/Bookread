//
//  CustomSearchBar.swift
//  Bookread
//
//  Created by Alexandr Bahno on 05.01.2026.
//

import SwiftUI

struct CustomSearchField: View {
    
    private let placeholder: String
    @Binding private var text: String
    @FocusState private var isFocused
    private let onTap: () -> Void
    
    init(
        placeholder: String,
        text: Binding<String>,
        onTap: @escaping () -> Void
    ) {
        self.placeholder = placeholder
        self._text = text
        self.onTap = onTap
    }
    
    var body: some View {
        HStack {
            HStack(alignment: .center, spacing: 3.flexible()) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.gray666666)
                    .frame(width: 18.flexible(), height: 18.flexible())
                    .padding(.trailing, 8.flexible())
                
                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .foregroundColor(Color.gray666666)
                )
                .dmSansRegular(size: 17.flexible())
                .autocorrectionDisabled(true)
                .focused($isFocused)
                .foregroundStyle(Color.text1A1A1A)
                
                if isFocused {
                    Button {
                        onTap()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(Color.gray666666)
                            .frame(width: 18.flexible(), height: 18.flexible())
                            .padding(.leading, 4.flexible())
                    }
                }
            }
            .padding(.horizontal, 12.flexible())
            .frame(height: 36.flexible())
            .frame(maxWidth: .infinity)
            .background(Color.secondaryE8DFD0.cornerRadius(10.flexible(), corners: .allCorners))
            .padding(.trailing, 4.flexible())
            
            if isFocused {
                Button {
                    self.isFocused = false
                    onTap()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 17.flexible(), weight: .regular))
                        .foregroundStyle(Color.primary2D5F5D)
                }
            }
        }
        .animation(.easeInOut, value: isFocused)
    }
}
