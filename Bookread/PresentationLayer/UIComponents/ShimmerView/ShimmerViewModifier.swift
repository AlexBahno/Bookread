//
//  ShimmerViewModifiel.swift
//  CityWeather
//
//  Created by Alexandr Bahno on 14.03.2026.
//

import SwiftUI

struct ShimmerViewModifier: ViewModifier {
    
    let speed: Double
    let color: Color
    let angle: Double
    let animateOpacity: Bool
    let animateScale: Bool
    @State var move = false
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let gradient = LinearGradient (
                        gradient: .init(
                            colors: [
                                color.opacity(0),
                                color.opacity(0.5),
                                color.opacity(0)
                            ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    Rectangle()
                        .fill(gradient)
                        .rotationEffect(.degrees(angle))
                        .frame(
                            width: geometry.size.width / 2.5,
                            height: geometry.size.height * 2
                        )
                        .offset(
                            x: move ? geometry.size.width * 1.1 : -geometry.size.width * 1.4,
                            y: -geometry.size.height / 2
                        )
                        .animation(
                            .linear(duration: speed).repeatForever(autoreverses: false),
                            value: move
                        )
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                move = true
                            }
                        }
                }
                .mask(content)
                .scaleEffect(animateScale ? (move ? 1 : 0.95) : 1)
                .opacity(animateScale ? (move ? 1 : 0.5) : 1)
                .animation(
                    (animateScale || animateOpacity) ?
                        .linear(duration: 1).repeatForever(autoreverses: true) : nil,
                    value: move
                )
            }
    }
}

extension View {
    func shimmer (
        speed: Double = 1.5,
        color: Color = .white,
        angle: Double = 0,
        animate0pacity: Bool = false,
        animateScale: Bool = false
    ) -> some View {
        self.modifier(
            ShimmerViewModifier(
                speed: speed,
                color: color,
                angle: angle,
                animateOpacity: animate0pacity,
                animateScale: animateScale
            )
        )
    }
}
