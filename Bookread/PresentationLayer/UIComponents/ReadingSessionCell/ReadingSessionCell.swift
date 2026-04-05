//
//  ReadingSessionCell.swift
//  Bookread
//
//  Created by Alexandr Bahno on 05.04.2026.
//

import SwiftUI

struct ReadingSessionCell: View {
    
    let session: ReadingSession
    let previousSession: ReadingSession?
    
    var body: some View {
        HStack(spacing: 16.flexible()) {
            dateAndTime
            
            cirleProgress
            
            HStack(spacing: .zero) {
                Spacer()
                
                sessionDetails
                
                Spacer()
                
                if let speedChange = calculateSpeedChange() {
                    TrendLineChart(
                        isImprovement: speedChange.isImprovement
                    )
                    .frame(width: 40.flexible(), height: 20.flexible())
                }
            }
        }
        .padding(.horizontal, 16.flexible())
        .padding(.vertical, 12.flexible())
        .background(Color.white)
        .cornerRadius(16.flexible())
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    var dateAndTime: some View {
        VStack(spacing: 4.flexible()) {
            Text(session.dateString)
                .font(.system(size: 14.flexible(), weight: .semibold))
                .foregroundColor(.primary2D5F5D)
            
            Text(session.formattedTime)
                .font(.system(size: 12.flexible()))
                .foregroundColor(.gray666666)
                .multilineTextAlignment(.center)
        }
        .frame(width: 70.flexible())
    }
    
    var cirleProgress: some View {
        ZStack {
            Circle()
                .stroke(.secondaryE8DFD0, lineWidth: 3.flexible())
                .frame(width: 60.flexible(), height: 60.flexible())
            
            Circle()
                .trim(from: 0, to: session.totalPercentage)
                .stroke(
                    .accentC17767,
                    style: StrokeStyle(lineWidth: 3.flexible(), lineCap: .round)
                )
                .frame(width: 60.flexible(), height: 60.flexible())
                .rotationEffect(.degrees(-90))
            
            Text("+\(String(format: "%.1f", session.sessionPercentage * 100))%")
                .font(.system(size: 13.flexible(), weight: .bold))
                .foregroundColor(.primary2D5F5D)
        }
    }
    
    var sessionDetails: some View {
        VStack(alignment: .leading, spacing: 8.flexible()) {
            HStack(spacing: 6.flexible()) {
                Image(systemName: "book.fill")
                    .font(.system(size: 12.flexible()))
                    .foregroundColor(.gray)
                Text("\(session.pagesRead) pages")
                    .font(.system(size: 14.flexible(), weight: .medium))
                    .foregroundColor(.primary)
            }
            
            if let speedChange = calculateSpeedChange() {
                HStack(spacing: 4.flexible()) {
                    Image(systemName: speedChange.isImprovement ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 12.flexible(), weight: .bold))
                        .foregroundColor(speedChange.isImprovement ? .primary2D5F5D : .accentC17767)
                    
                    Text(speedChange.description)
                        .font(.system(size: 12.flexible(), weight: .medium))
                        .foregroundColor(speedChange.isImprovement ? .primary2D5F5D : .accentC17767)
                }
            } else {
                Text("First session")
                    .font(.system(size: 12.flexible()))
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Speed Calculation
    private func calculateSpeedChange() -> SpeedChange? {
        guard let previous = previousSession else {
            return nil
        }
        
        // Calculate reading speed (pages per minute)
        let currentDuration: Double = session.endTime.timeIntervalSince(session.startTime) / 60.0
        let previousDuration: Double = previous.endTime.timeIntervalSince(previous.startTime) / 60.0
        
        guard currentDuration > 0, previousDuration > 0 else {
            return nil
        }
        
        let currentSpeed = Double(session.pagesRead) / currentDuration
        let previousSpeed = Double(previous.pagesRead) / previousDuration
        
        guard previousSpeed > 0 else {
            return nil
        }
        
        let percentChange = ((currentSpeed - previousSpeed) / previousSpeed) * 100
        let isImprovement = currentSpeed > previousSpeed
        
        return SpeedChange(
            isImprovement: isImprovement,
            percentChange: abs(percentChange)
        )
    }
    
    private var durationFormatted: String {
        let duration = session.endTime.timeIntervalSince(session.startTime)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Trend Line Chart
struct TrendLineChart: View {
    
    let isImprovement: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midHeight = height / 2
                
                // Start point (left, middle)
                path.move(to: CGPoint(x: 0, y: midHeight))
                
                // Control point for curve
                let controlX = width * 0.5
                let controlY = isImprovement ? midHeight - (height * 0.3) : midHeight + (height * 0.3)
                
                // End point
                let endX = width
                let endY = isImprovement ? midHeight - (height * 0.4) : midHeight + (height * 0.4)
                
                // Quadratic curve
                path.addQuadCurve(
                    to: CGPoint(x: endX, y: endY),
                    control: CGPoint(x: controlX, y: controlY)
                )
            }
            .stroke(
                isImprovement ? .primary2D5F5D : .accentC17767,
                style: StrokeStyle(lineWidth: 2.5.flexible(), lineCap: .round)
            )
            
            // End point circle
            Circle()
                .fill(isImprovement ? .primary2D5F5D : .accentC17767)
                .frame(width: 6.flexible(), height: 6.flexible())
                .position(
                    x: geometry.size.width,
                    y: isImprovement ?
                    geometry.size.height / 2 - (geometry.size.height * 0.4) :
                        geometry.size.height / 2 + (geometry.size.height * 0.4)
                )
        }
    }
}
