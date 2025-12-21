//
//  WorkoutSessionView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData

struct WorkoutSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = WorkoutViewModel()
    @State private var showingExitConfirmation = false
    @State private var showingCompletion = false
    
    let routine: Routine
    
    var body: some View {
        ZStack {
            Color.steadyBackground.ignoresSafeArea()
            
            if viewModel.isWorkoutActive {
                activeWorkoutView
            } else if showingCompletion {
                WorkoutCompleteView(viewModel: viewModel) {
                    dismiss()
                }
            } else {
                workoutPreviewView
            }
        }
        .confirmationDialog(
            "End Workout?",
            isPresented: $showingExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Workout", role: .destructive) {
                viewModel.cancelWorkout()
                dismiss()
            }
            Button("Continue Workout", role: .cancel) {}
        } message: {
            Text("Your progress will not be saved if you end now.")
        }
    }
    
    // MARK: - Workout Preview
    private var workoutPreviewView: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Close button
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.steadyTextSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            Spacer()
            
            // Routine info
            VStack(spacing: Theme.Spacing.md) {
                Image(systemName: routine.category.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(Color.steadyGradient)
                
                Text(routine.name)
                    .font(Typography.displayMedium)
                    .foregroundColor(.steadyTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(routine.routineDescription)
                    .font(Typography.bodyLarge)
                    .foregroundColor(.steadyTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
                
                HStack(spacing: Theme.Spacing.xl) {
                    Label("\(Int(routine.estimatedDuration)) min", systemImage: "clock")
                    Label("\(routine.exerciseIDs.count > 0 ? routine.exerciseIDs.count : 5) exercises", systemImage: "list.bullet")
                }
                .font(Typography.labelMedium)
                .foregroundColor(.steadyTextTertiary)
            }
            
            Spacer()
            
            // Start button
            Button {
                viewModel.startWorkout(routine: routine, modelContext: modelContext)
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Workout")
                }
            }
            .buttonStyle(.primary)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
        }
    }
    
    // MARK: - Active Workout View
    private var activeWorkoutView: some View {
        VStack(spacing: 0) {
            // Top bar
            workoutTopBar
            
            Spacer()
            
            // Current exercise
            if let exercise = viewModel.currentExercise {
                currentExerciseView(exercise: exercise)
            }
            
            Spacer()
            
            // Timer
            timerView
            
            // Controls
            workoutControls
        }
    }
    
    private var workoutTopBar: some View {
        HStack {
            Button {
                showingExitConfirmation = true
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.steadyTextSecondary)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(routine.name)
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyTextPrimary)
                
                Text("\(viewModel.currentExerciseIndex + 1) of \(viewModel.exercises.count)")
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextSecondary)
            }
            
            Spacer()
            
            // Heart rate if available
            if let heartRate = WatchConnectivityService.shared.currentHeartRate {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(Int(heartRate))")
                        .font(Typography.labelMedium)
                }
            }
        }
        .padding(Theme.Spacing.lg)
    }
    
    private func currentExerciseView(exercise: Exercise) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Exercise icon
            ZStack {
                Circle()
                    .fill(Color(hex: exercise.category.color).opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: exercise.category.icon)
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: exercise.category.color))
            }
            
            // Exercise name
            Text(viewModel.isResting ? "Rest" : exercise.name)
                .font(Typography.displaySmall)
                .foregroundColor(.steadyTextPrimary)
            
            // Instructions
            if !viewModel.isResting {
                Text(exercise.instructions.first ?? "")
                    .font(Typography.bodyLarge)
                    .foregroundColor(.steadyTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            } else {
                Text("Catch your breath and get ready for the next exercise")
                    .font(Typography.bodyLarge)
                    .foregroundColor(.steadyTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
        }
    }
    
    private var timerView: some View {
        VStack(spacing: Theme.Spacing.sm) {
            // Main timer
            Text(viewModel.formattedTimeRemaining)
                .font(Typography.timer)
                .foregroundColor(viewModel.isResting ? .steadySuccess : .steadyPrimary)
                .monospacedDigit()
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.steadyBorder)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(viewModel.isResting ? Color.steadySuccess : Color.steadyPrimary)
                        .frame(width: geometry.size.width * viewModel.progress, height: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, Theme.Spacing.xl)
            
            // Total time
            Text("Total: \(viewModel.formattedTotalTime)")
                .font(Typography.caption)
                .foregroundColor(.steadyTextTertiary)
        }
        .padding(.vertical, Theme.Spacing.lg)
    }
    
    private var workoutControls: some View {
        HStack(spacing: Theme.Spacing.xl) {
            // Skip button
            Button {
                viewModel.skipExercise()
            } label: {
                Image(systemName: "forward.fill")
            }
            .buttonStyle(LargeIconButtonStyle(backgroundColor: .steadyTextTertiary, size: 56))
            
            // Play/Pause button
            Button {
                if viewModel.isPaused {
                    viewModel.resumeWorkout()
                } else {
                    viewModel.pauseWorkout()
                }
            } label: {
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
            }
            .buttonStyle(LargeIconButtonStyle(size: 72))
            
            // Complete exercise early
            Button {
                viewModel.completeExercise()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(LargeIconButtonStyle(backgroundColor: .steadySuccess, size: 56))
        }
        .padding(.bottom, Theme.Spacing.xxl)
    }
}

// MARK: - Workout Complete View
struct WorkoutCompleteView: View {
    let viewModel: WorkoutViewModel
    let onDismiss: () -> Void
    
    @State private var rating: Int = 0
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            // Celebration
            Image(systemName: "party.popper.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.celebrationGradient)
            
            Text("Workout Complete!")
                .font(Typography.displayMedium)
                .foregroundColor(.steadyTextPrimary)
            
            Text("Great job! You're one step closer to your goals.")
                .font(Typography.bodyLarge)
                .foregroundColor(.steadyTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
            
            // Stats
            HStack(spacing: Theme.Spacing.xl) {
                StatBubble(value: viewModel.formattedTotalTime, label: "Duration")
                StatBubble(value: "\(viewModel.completedExerciseIDs.count)", label: "Exercises")
                StatBubble(value: "\(Int(viewModel.progress * 100))%", label: "Completed")
            }
            
            // Rating
            VStack(spacing: Theme.Spacing.sm) {
                Text("How was this workout?")
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyTextSecondary)
                
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            rating = star
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 32))
                                .foregroundColor(.steadyWarning)
                        }
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.lg)
            
            Spacer()
            
            Button {
                onDismiss()
            } label: {
                Text("Done")
            }
            .buttonStyle(.primary)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
        }
    }
}

struct StatBubble: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(value)
                .font(Typography.headlineLarge)
                .foregroundColor(.steadyPrimary)
            
            Text(label)
                .font(Typography.caption)
                .foregroundColor(.steadyTextSecondary)
        }
        .frame(width: 80)
    }
}

#Preview {
    WorkoutSessionView(routine: Routine.sampleRoutines[0])
}
