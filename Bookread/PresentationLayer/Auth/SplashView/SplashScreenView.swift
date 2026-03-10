//
//  ContentView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 22.12.2025.
//

import SwiftUI
import Lottie

struct SplashScreenView: View {
    
    var animationEnds: (() -> Void)?
    @State private var isTextHidden = true
    
    var body: some View {
        ZStack {
            Color
                .backgroundFAFAF8
            
            container
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            isTextHidden.toggle()
                        }
                    }
                }
        }
        .ignoresSafeArea()
    }
    
    var container: some View {
        VStack(spacing: 8.flexible()) {
            LottieView(animation: .named("SplashAnimation"))
                .resizable()
                .playing()
                .animationDidFinish { _ in
                    animationEnds?()
                }
                .scaledToFit()
            
            if !isTextHidden {
                Text("Bookread")
                    .interRegular(size: 48.flexible())
                    .foregroundStyle(.text1A1A1A)
                    .multilineTextAlignment(.center)
                    .transition(
                        .move(edge: .bottom)
                            .combined(with: .opacity)
                            .animation(.easeInOut(duration: 1))
                    )
            }
        }
    }
}
