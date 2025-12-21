//
//  WatchHeartRateView.swift
//  SteadyStride Watch App
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

/// Heart rate monitoring view for Apple Watch
struct WatchHeartRateView: View {
    @State private var heartRate: Int = 72
    @State private var heartRateZone: HeartRateZone = .normal
    @State private var heartRateHistory: [Int] = [68, 70, 72, 75, 73, 72]
    
    var body: some View {
        VStack(spacing: 12) {
            // Heart icon with animation
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundColor(heartRateZone.color)
                .symbolEffect(.pulse)
            
            // Current heart rate
            Text("\(heartRate)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("BPM")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Heart rate zone
            Text(heartRateZone.description)
                .font(.caption2)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(heartRateZone.color.opacity(0.3))
                )
                .foregroundColor(heartRateZone.color)
            
            // Zone guidance
            if heartRateZone == .high {
                Text("Slow down and breathe")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else if heartRateZone == .low {
                Text("Keep moving!")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
}

enum HeartRateZone {
    case low
    case normal
    case elevated
    case high
    
    var description: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .elevated: return "Elevated"
        case .high: return "High"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .yellow
        case .high: return .red
        }
    }
    
    static func zone(for heartRate: Int, age: Int = 65) -> HeartRateZone {
        let maxHR = 220 - age
        let percentage = Double(heartRate) / Double(maxHR)
        
        switch percentage {
        case ..<0.5: return .low
        case 0.5..<0.7: return .normal
        case 0.7..<0.85: return .elevated
        default: return .high
        }
    }
}

#Preview {
    WatchHeartRateView()
}
