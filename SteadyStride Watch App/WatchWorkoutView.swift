//
//  WatchWorkoutView.swift
//  SteadyStride Watch App
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

/// Main workout view for Apple Watch
struct WatchWorkoutView: View {
    @State private var currentExercise: String = "Chair Stand"
    @State private var timeRemaining: Int = 30
    @State private var isPaused: Bool = false
    @State private var exerciseIndex: Int = 1
    @State private var totalExercises: Int = 5
    @State private var heartRate: Int = 72
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Exercise Name
                Text(currentExercise)
                    .font(.headline)
                    .foregroundColor(.teal)
                    .multilineTextAlignment(.center)
                
                // Timer
                Text(formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                // Progress
                Text("\(exerciseIndex) of \(totalExercises)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Heart Rate
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(heartRate)")
                        .font(.system(.body, design: .rounded))
                }
                .padding(.top, 4)
                
                // Controls
                HStack(spacing: 16) {
                    // Skip
                    Button {
                        skipExercise()
                    } label: {
                        Image(systemName: "forward.fill")
                    }
                    .buttonStyle(.bordered)
                    
                    // Play/Pause
                    Button {
                        isPaused.toggle()
                    } label: {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    
                    // Complete
                    Button {
                        completeExercise()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                }
                .padding(.top, 8)
            }
        }
    }
    
    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func skipExercise() {
        // Skip to next exercise
    }
    
    private func completeExercise() {
        // Complete current exercise
    }
}

#Preview {
    WatchWorkoutView()
}
