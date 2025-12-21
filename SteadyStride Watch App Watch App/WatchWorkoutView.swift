//
//  WatchWorkoutView.swift
//  SteadyStride Watch App
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

/// Main workout view for Apple Watch
struct WatchWorkoutView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @State private var currentExercise: String = "Chair Stand"
    @State private var timeRemaining: Int = 30
    @State private var isPaused: Bool = false
    @State private var exerciseIndex: Int = 1
    @State private var totalExercises: Int = 5
    @State private var heartRate: Int = 72
    @State private var timer: Timer?
    @State private var totalDuration: TimeInterval = 0
    @Environment(\.dismiss) private var dismiss
    
    private let exercises = [
        ("Chair Stand", 30),
        ("Weight Shifts", 45),
        ("Heel-to-Toe Walk", 60),
        ("Calf Raises", 45),
        ("Deep Breathing", 60)
    ]
    
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
                        togglePause()
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
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard !isPaused else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
                totalDuration += 1
            } else {
                completeExercise()
            }
        }
    }
    
    private func togglePause() {
        isPaused.toggle()
    }
    
    private func skipExercise() {
        moveToNextExercise()
    }
    
    private func completeExercise() {
        if exerciseIndex < totalExercises {
            moveToNextExercise()
        } else {
            finishWorkout()
        }
    }
    
    private func moveToNextExercise() {
        if exerciseIndex < exercises.count {
            exerciseIndex += 1
            let exercise = exercises[exerciseIndex - 1]
            currentExercise = exercise.0
            timeRemaining = exercise.1
        } else {
            finishWorkout()
        }
    }
    
    private func finishWorkout() {
        timer?.invalidate()
        connectivity.sendWorkoutComplete(duration: totalDuration, exercisesCompleted: exerciseIndex)
        dismiss()
    }
}

#Preview {
    WatchWorkoutView()
        .environment(WatchConnectivityManager.shared)
}
