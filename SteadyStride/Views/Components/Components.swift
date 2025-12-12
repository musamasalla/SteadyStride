//
//  Components.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

// MARK: - Loading Indicator
struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.steadyPrimary)
            
            Text(message)
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.steadyBackground)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.steadyTextTertiary)
            
            Text(title)
                .font(Typography.headlineMedium)
                .foregroundColor(.steadyTextPrimary)
            
            Text(message)
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(.primary)
                .padding(.top, Theme.Spacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Theme.Spacing.xl)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var iconColor: Color = .steadyPrimary
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 28)
            
            Text(title)
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(Typography.labelMedium)
                .foregroundColor(.steadyTextPrimary)
        }
        .padding(Theme.Spacing.md)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Typography.labelMedium)
                        .foregroundColor(.steadyPrimary)
                }
            }
        }
    }
}

// MARK: - Streak Badge
struct StreakBadge: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: "flame.fill")
                .foregroundColor(.steadySecondary)
            
            Text("\(count)")
                .font(Typography.labelLarge)
                .foregroundColor(.steadyTextPrimary)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(
            Capsule()
                .fill(Color.steadySecondary.opacity(0.15))
        )
    }
}

// MARK: - Timer Display
struct TimerDisplay: View {
    let timeRemaining: TimeInterval
    var isActive: Bool = true
    var fontSize: CGFloat = 72
    
    var body: some View {
        Text(formattedTime)
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .foregroundColor(isActive ? .steadyPrimary : .steadyTextTertiary)
            .monospacedDigit()
    }
    
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Heart Rate Display
struct HeartRateDisplay: View {
    let heartRate: Double?
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .symbolEffect(.pulse)
            
            if let hr = heartRate {
                Text("\(Int(hr))")
                    .font(Typography.labelLarge)
                    .foregroundColor(.steadyTextPrimary)
                
                Text("BPM")
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextSecondary)
            } else {
                Text("--")
                    .font(Typography.labelLarge)
                    .foregroundColor(.steadyTextTertiary)
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(
            Capsule()
                .fill(Color.red.opacity(0.1))
        )
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: Difficulty
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Image(systemName: "flame.fill")
                    .font(.system(size: 10))
                    .foregroundColor(index < difficultyLevel ? Color(hex: difficulty.color) : .steadyTextTertiary.opacity(0.3))
            }
        }
    }
    
    private var difficultyLevel: Int {
        switch difficulty {
        case .easy: return 1
        case .moderate: return 2
        case .challenging: return 3
        }
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: ExerciseCategory
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            Image(systemName: category.icon)
                .font(.system(size: 12))
            
            Text(category.rawValue)
                .font(Typography.caption)
        }
        .foregroundColor(Color(hex: category.color))
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xxs)
        .background(
            Capsule()
                .fill(Color(hex: category.color).opacity(0.15))
        )
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let name: String
    var color: String = "#2A9D8F"
    var size: CGFloat = 44
    
    var body: some View {
        Circle()
            .fill(Color(hex: color))
            .frame(width: size, height: size)
            .overlay(
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(.white)
            )
    }
}

// MARK: - Circular Progress
struct CircularProgress: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 60
    var color: Color = .steadyPrimary
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Confetti View (for celebrations)
struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { index in
                ConfettiPiece(animate: animate, delay: Double(index) * 0.02)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    let animate: Bool
    let delay: Double
    
    @State private var position = CGPoint(x: CGFloat.random(in: 0...1), y: -0.1)
    
    let colors: [Color] = [.steadyPrimary, .steadySecondary, .steadySuccess, .steadyWarning]
    
    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(colors.randomElement() ?? .steadyPrimary)
                .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
                .position(
                    x: position.x * geometry.size.width,
                    y: animate ? geometry.size.height * 1.2 : position.y * geometry.size.height
                )
                .animation(
                    .easeIn(duration: Double.random(in: 2...4))
                    .delay(delay),
                    value: animate
                )
        }
    }
}

// MARK: - Previews
#Preview("Components") {
    ScrollView {
        VStack(spacing: 20) {
            StreakBadge(count: 7)
            TimerDisplay(timeRemaining: 90)
            HeartRateDisplay(heartRate: 72)
            DifficultyBadge(difficulty: .moderate)
            CircularProgress(progress: 0.7)
            AvatarView(name: "John")
        }
        .padding()
    }
}
