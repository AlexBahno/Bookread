//
//  CornerShape.swift
//  QRCraft
//
//  Created by Alexandr Bahno on 25.06.2025.
//

import SwiftUI

struct CornerShapeView: View {
    var body: some View {
        CornerShape()
            .stroke(
                Color.primary2D5F5D,
                style: StrokeStyle(
                    lineWidth: 7.5.flexible(),
                    lineCap: .round,
                    lineJoin: .round
                )
            )
    }
}

struct CornerShape: Shape {
    
    var cornerLength: CGFloat = 20.flexible()
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 1. Top-Left Corner
        // Move pen down the left edge, draw up to the corner, then right
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerLength))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + cornerLength, y: rect.minY))
        
        // 2. Top-Right Corner
        // Move pen left of the corner, draw right to the corner, then down
        path.move(to: CGPoint(x: rect.maxX - cornerLength, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerLength))
        
        // 3. Bottom-Right Corner
        // Move pen up from the corner, draw down to the corner, then left
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerLength))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerLength, y: rect.maxY))
        
        // 4. Bottom-Left Corner
        // Move pen right of the corner, draw left to the corner, then up
        path.move(to: CGPoint(x: rect.minX + cornerLength, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cornerLength))
        
        return path
    }
}
