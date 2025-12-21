//
//  WatchQuickExercisesView.swift
//  SteadyStride Watch App
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
#if os(watchOS)
import WatchKit
#endif

/// Quick exercises picker for Apple Watch
struct WatchQuickExercisesView: View {
    
    struct QuickExercise: Identifiable {
        let id = UUID()
        let name: String
        let duration: Int
        let icon: String
        let color: Color
    }
    
    private let exercises: [QuickExercise] = [
        QuickExercise(name: "Deep Breathing", duration: 60, icon: "wind", color: .blue),
        QuickExercise(name: "Chair Stand", duration: 45, icon: "figure.stand", color: .green),
        QuickExercise(name: "Weight Shifts", duration: 30, icon: "arrow.left.arrow.right", color: .orange),
        QuickExercise(name: "Calf Raises", duration: 45, icon: "figure.walk", color: .teal),
        QuickExercise(name: "Neck Stretches", duration: 30, icon: "person.fill", color: .purple)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(exercises) { exercise in
                    NavigationLink {
                        QuickExerciseActiveView(exercise: exercise)
                    } label: {
                        HStack {
                            Image(systemName: exercise.icon)
                                .foregroundColor(exercise.color)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text("\(exercise.duration)s")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Quick")
    }
}

/// Active quick exercise view
struct QuickExerciseActiveView: View {
    let exercise: WatchQuickExercisesView.QuickExercise
    @State private var timeRemaining: Int
    @State private var isActive: Bool = false
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    init(exercise: WatchQuickExercisesView.QuickExercise) {
        self.exercise = exercise
        _timeRemaining = State(initialValue: exercise.duration)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: exercise.icon)
                .font(.system(size: 40))
                .foregroundColor(exercise.color)
            
            Text(exercise.name)
                .font(.headline)
            
            Text(formattedTime)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            Button {
                toggleTimer()
            } label: {
                Image(systemName: isActive ? "pause.fill" : "play.fill")
                    .font(.title2)
            }
            .buttonStyle(.borderedProminent)
            .tint(exercise.color)
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
    
    private func toggleTimer() {
        isActive.toggle()
        
        if isActive {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    isActive = false
                    // Haptic feedback
                    #if os(watchOS)
                    WKInterfaceDevice.current().play(.success)
                    #endif
                }
            }
        } else {
            timer?.invalidate()
        }
    }
}

#Preview {
    WatchQuickExercisesView()
}
