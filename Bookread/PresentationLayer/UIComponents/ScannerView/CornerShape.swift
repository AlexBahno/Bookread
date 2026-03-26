//
//  CornerShape.swift
//  QRCraft
//
//  Created by Alexandr Bahno on 25.06.2025.
//

import SwiftUI

struct CornerShape: View {
    
    var rotationDegrees: [Double] = [0, 90, 180, 270]
    var paddingSide: [(x: Double, y: Double)] = [
        (-10.flexible(), 10.flexible()),
        (-10.flexible(), -10.flexible()),
        (10.flexible(), -10.flexible()),
        (10.flexible(), 10.flexible())
    ]
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.clear)
            
            ForEach(0..<4) { item in
                corner
                    .rotationEffect(Angle(degrees: rotationDegrees[item]))
                    .offset(x: paddingSide[item].x, y: paddingSide[item].y)
            }
        }
    }
    
    var corner: some View {
        RoundedRectangle(cornerRadius: 20.flexible())
            .trim(from: 0.3, to: 0.45)
            .stroke(
                Color.primary2D5F5D,
                style: StrokeStyle(lineWidth: 9.flexible(), lineCap: .round)
            )
    }
}
