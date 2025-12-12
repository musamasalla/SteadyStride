//
//  WatchQuickExercisesView.swift
//  SteadyStride Watch App
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

/// Quick exercises selection for Apple Watch
struct WatchQuickExercisesView: View {
    
    let quickExercises = [
        QuickExercise(name: "Chair Stand", icon: "chair.fill", duration: 30),
        QuickExercise(name: "Balance Hold", icon: "figure.stand", duration: 30),
        QuickExercise(name: "Heel Raises", icon: "foot.fill", duration: 45),
        QuickExercise(name: "Arm Circles", icon: "figure.arms.open", duration: 30),
        QuickExercise(name: "Breathing", icon: "wind", duration: 60)
    ]
    
    var body: some View {
        List(quickExercises) { exercise in
            NavigationLink {
                WatchSingleExerciseView(exercise: exercise)
            } label: {
                HStack {
                    Image(systemName: exercise.icon)
                        .foregroundColor(.teal)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading) {
                        Text(exercise.name)
                            .font(.caption)
                        Text("\(exercise.duration)s")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Quick Start")
    }
}

struct QuickExercise: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let duration: Int
}

/// Single exercise view for quick workout
struct WatchSingleExerciseView: View {
    let exercise: QuickExercise
    @State private var timeRemaining: Int
    @State private var isActive: Bool = false
    @State private var isComplete: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(exercise: QuickExercise) {
        self.exercise = exercise
        self._timeRemaining = State(initialValue: exercise.duration)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if isComplete {
                // Completion view
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                
                Text("Done!")
                    .font(.headline)
                
                Button("Back") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            } else {
                // Exercise view
                Image(systemName: exercise.icon)
                    .font(.system(size: 36))
                    .foregroundColor(.teal)
                
                Text(exercise.name)
                    .font(.headline)
                
                Text("\(timeRemaining)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(isActive ? .white : .gray)
                
                Button {
                    if isActive {
                        // Pause
                        isActive = false
                    } else {
                        // Start
                        isActive = true
                        startTimer()
                    }
                } label: {
                    Image(systemName: isActive ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
            }
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if !isActive {
                timer.invalidate()
                return
            }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                isComplete = true
            }
        }
    }
}

#Preview {
    WatchQuickExercisesView()
}
