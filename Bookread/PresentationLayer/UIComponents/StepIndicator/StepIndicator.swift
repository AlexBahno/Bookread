//
//  SwiftUIView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 28.12.2025.
//

import SwiftUI

struct StepIndicator: View {
    
    @Binding var currentStep: OnBoardingSteps
    
    var body: some View {
        HStack(spacing: 8.flexible()) {
            ForEach(OnBoardingSteps.allCases) { step in
                RoundedRectangle(cornerRadius: 4.flexible())
                    .fill(isCurrentStep(step) ? .primary2D5F5D : Color(hex: "#dddddd"))
                    .frame(
                        width: isCurrentStep(step) ? 32.flexible() : 8.flexible(),
                        height: 8.flexible()
                    )
            }
        }
    }
    
    func isCurrentStep(_ step: OnBoardingSteps) -> Bool {
        currentStep == step
    }
}
