//
//  PageSetupSheet.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29.03.2026.
//

import SwiftUI

struct PageSetupSheet: View {
    enum Step {
        case totalPages
        case startPage
    }
    
    @Binding var totalPages: Int
    @Binding var startPage: Int
    @State private var currentStep: Step = .totalPages
    @Environment(\.dismiss) var dismiss
    
    var onComplete: () -> Void
    
    var body: some View {
        Group {
            switch currentStep {
            case .totalPages:
                PageInputSheet(
                    pageCount: $totalPages,
                    state: .totalPages
                ) {
                    currentStep = .startPage
                }
                
            case .startPage:
                PageInputSheet(
                    pageCount: $startPage,
                    state: .startPage
                ) {
                    dismiss()
                    onComplete()
                }
            }
        }
        .animation(.easeInOut, value: currentStep)
    }
}
