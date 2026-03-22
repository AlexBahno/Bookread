//
//  AppStyleButton.swift
//  Bookread
//
//  Created by Alexandr Bahno on 27.12.2025.
//

import SwiftUI

enum AppStyleType {
    case withWhiteBackground
    case withGreenBackground
}

struct AppStyleButton: View {
    
    let text: String
    let image: Image?
    let type: AppStyleType
    let cornerRadius: CGFloat
    let action: () -> Void
    let isDisabled: Bool
    
    init(
        text: String,
        image: Image? = nil,
        type: AppStyleType,
        cornerRadius: CGFloat = 16.flexible(),
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.image = image
        self.type = type
        self.cornerRadius = cornerRadius
        self.isDisabled = isDisabled
        self.action = action
    }

    init(
        title: String,
        image: Image? = nil,
        type: AppStyleType,
        cornerRadius: CGFloat = 16.flexible(),
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            text: title,
            image: image,
            type: type,
            cornerRadius: cornerRadius,
            isDisabled: isDisabled,
            action: action
        )
    }
    
    var textColor: Color {
        switch type {
        case .withWhiteBackground:
            isDisabled ? .gray9E9E9E : .primary2D5F5D
        case .withGreenBackground:
            isDisabled ? .gray9E9E9E : .white
        }
    }
    
    var backgroundColor: Color {
        switch type {
        case .withWhiteBackground:
                .backgroundFAFAF8
        case .withGreenBackground:
            isDisabled ? .grayE0E0E0 : .primary2D5F5D
        }
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12.flexible()) {
                if let image {
                    image
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(textColor)
                        .frame(width: 20.flexible(), height: 20.flexible())
                }
                
                Text(text)
                    .interRegular(size: 20.flexible())
                    .fontWeight(.medium)
                    .foregroundStyle(textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48.flexible())
            .padding(.horizontal, 16.flexible())
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            }
            .overlay {
                if type == .withWhiteBackground {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            isDisabled ? .grayE0E0E0 : Color.primary2D5F5D,
                            lineWidth: 1.flexible()
                        )
                }
            }
            .opacity(isDisabled ? 0.6 : 1)
        }
        .disabled(isDisabled)
    }
}

