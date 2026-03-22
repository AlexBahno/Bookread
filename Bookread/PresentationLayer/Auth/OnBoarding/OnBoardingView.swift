//
//  OnBoardingView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 27.12.2025.
//

import SwiftUI

struct OnBoardingRouter {
    let startSignUpFlow: () -> Void
    let startLoginFlow: () -> Void
}

struct OnBoardingView: View {
    
    @AppStorage(AppStorageConst.onBoardingPresented) var alreadyPresentedOnboarding: Bool = false
    @State private var onBoardingStep: OnBoardingSteps = .track
    
    let router: OnBoardingRouter
    
    var body: some View {
        container
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundFAFAF8)
            .animation(.easeInOut, value: onBoardingStep)
            .toolbarVisibility(.hidden, for: .navigationBar)
    }
    
    var container: some View {
        VStack(spacing: .zero) {
            Spacer()
            TabView(selection: $onBoardingStep) {
                stepView(.track)
                    .tag(OnBoardingSteps.track)
                
                stepView(.share)
                    .tag(OnBoardingSteps.share)
                
                stepView(.discover)
                    .tag(OnBoardingSteps.discover)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
                        
            StepIndicator(currentStep: $onBoardingStep)
                .padding(.bottom, 56.flexible())
                        
            authButtons
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func stepView(_ step: OnBoardingSteps) -> some View {
        VStack(spacing: .zero) {
            Image(systemName: step.image)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.primary2D5F5D)
                .font(.system(size: 80.flexible()))
                .fontWeight(.medium)
                .frame(width: 120.flexible(), height: 120.flexible())
                .padding(.bottom, 56.flexible())
            
            Text(step.title)
                .interRegular(size: 28.flexible())
                .fontWeight(.medium)
                .foregroundStyle(.text1A1A1A)
                .multilineTextAlignment(.center)
                .padding([.horizontal, .bottom], 16.flexible())
            
            Text(step.description)
                .interRegular(size: 18.flexible())
                .foregroundStyle(Color.gray666666)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16.flexible())
        }
    }
    
    var authButtons: some View {
        VStack(spacing: 8.flexible()) {
            AppStyleButton(
                text: "Create Account",
                type: .withGreenBackground
            ) {
                router.startSignUpFlow()
            }
            
            AppStyleButton(
                text: "Login",
                type: .withWhiteBackground
            ) {
                router.startLoginFlow()
            }
        }
        .padding(.horizontal, 16.flexible())
    }
}
