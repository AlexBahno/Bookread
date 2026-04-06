//
//  PageInputSheet.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29.03.2026.
//

import SwiftUI

struct PageInputSheet: View {
    
    enum InputStates {
        case totalPages
        case startPage
        case endPage
    }
    
    @Environment(\.dismiss) var dismiss
    @Binding var pageCount: Int
    @State private var inputText: String = ""
    
    let state: InputStates
    let completion: () -> Void
    
    init(pageCount: Binding<Int>, state: InputStates, completion: @escaping () -> Void) {
        self._pageCount = pageCount
        if state == .startPage && pageCount.wrappedValue != 0  {
            self._inputText = .init(initialValue: "\(pageCount.wrappedValue)")
        }
        self.state = state
        self.completion = completion
    }
    
    var title: String {
        switch state {
        case .totalPages:
            "How many pages?"
        case .startPage:
            "From which page you start?"
        case .endPage:
            "On which page have you stopped?"
        }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundFAFAF8
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text(title)
                        .font(.system(size: 24.flexible(), weight: .bold))
                        .foregroundColor(.primary2D5F5D)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 30.flexible())
                .padding(.horizontal, 20.flexible())
                
                Spacer()
                
                // Input Display
                VStack(spacing: 8) {
                    Text(inputText.isEmpty ? "0" : inputText)
                        .font(.system(size: 64.flexible(), weight: .bold, design: .rounded))
                        .foregroundColor(inputText.isEmpty ? .gray.opacity(0.3) : .text1A1A1A)
                        .frame(maxWidth: .infinity)
                        .frame(height: 80.flexible())
                    
                    Text("pages")
                        .font(.system(size: 17.flexible()))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 20.flexible())
                
                Spacer()
                
                // Numpad
                VStack(spacing: 12.flexible()) {
                    // Rows 1-3
                    ForEach(0..<3) { row in
                        HStack(spacing: 12.flexible()) {
                            ForEach(1..<4) { col in
                                let number = row * 3 + col
                                NumpadButton(
                                    text: "\(number)",
                                    backgroundColor: .white,
                                    textColor: .text1A1A1A
                                ) {
                                    appendNumber(number)
                                }
                            }
                        }
                    }
                    
                    // Bottom row: Clear, 0, Delete
                    HStack(spacing: 12) {
                        NumpadButton(
                            text: "C",
                            backgroundColor: .secondaryE8DFD0,
                            textColor: .primary2D5F5D
                        ) {
                            clearInput()
                        }
                        
                        NumpadButton(
                            text: "0",
                            backgroundColor: .white,
                            textColor: .text1A1A1A
                        ) {
                            appendNumber(0)
                        }
                        
                        NumpadButton(
                            icon: "delete.left.fill",
                            backgroundColor: .secondaryE8DFD0,
                            textColor: .accentC17767
                        ) {
                            deleteLastDigit()
                        }
                    }
                }
                .padding(.horizontal, 20.flexible())
                
                // Confirm Button
                AppStyleButton(
                    text: "Confirm",
                    image: Image(systemName: "checkmark.circle.fill"),
                    type: .withGreenBackground,
                    isDisabled: !isInputValid
                ) {
                    confirmPageCount()
                }
                .padding(.horizontal, 20.flexible())
                .padding(.top, 24.flexible())
                .padding(.bottom, 40.flexible())
                .animation(.easeInOut, value: isInputValid)
            }
        }
    }
    
    private var isInputValid: Bool {
        guard let count = Int(inputText), count > 0 else {
            return false
        }
        return true
    }
    
    // MARK: - Actions
    private func appendNumber(_ number: Int) {
        // Limit to reasonable page count (9999 pages max)
        if inputText.count < 4 {
            inputText += "\(number)"
        }
    }
    
    private func deleteLastDigit() {
        if !inputText.isEmpty {
            inputText.removeLast()
        }
    }
    
    private func clearInput() {
        inputText = ""
    }
    
    private func confirmPageCount() {
        if let count = Int(inputText), count > 0 {
            pageCount = count
            completion()
            if state != .totalPages {
                dismiss()
            }
        }
    }
}

// MARK: - Numpad Button Component
struct NumpadButton: View {
    let text: String?
    let icon: String?
    let backgroundColor: Color
    let textColor: Color
    let action: () -> Void
    
    init(
        text: String? = nil,
        icon: String? = nil,
        backgroundColor: Color,
        textColor: Color,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 24.flexible(), weight: .medium))
                } else if let text = text {
                    Text(text)
                        .font(.system(size: 28.flexible(), weight: .medium))
                }
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 60.flexible())
            .background(backgroundColor)
            .cornerRadius(12.flexible())
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
    }
}
