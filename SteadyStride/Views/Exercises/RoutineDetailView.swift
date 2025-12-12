//
//  RoutineDetailView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @State private var showingWorkout = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                // Header
                routineHeader
                
                // Quick Stats
                quickStats
                
                // Exercise List
                exerciseList
                
                // Start Button
                startButton
            }
            .padding(Theme.Spacing.lg)
        }
        .background(Color.steadyBackground)
        .navigationTitle(routine.name)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingWorkout) {
            WorkoutSessionView(routine: routine)
        }
    }
    
    // MARK: - Header
    private var routineHeader: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Category Badge
            CategoryBadge(category: routine.category)
            
            // Description
            Text(routine.routineDescription)
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextSecondary)
                .multilineTextAlignment(.center)
            
            // Tags
            HStack(spacing: Theme.Spacing.sm) {
                DifficultyBadge(difficulty: routine.difficulty)
                
                Text("•")
                    .foregroundColor(.steadyTextTertiary)
                
                Label("\(Int(routine.estimatedDuration)) min", systemImage: "clock")
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyTextSecondary)
                
                Text("•")
                    .foregroundColor(.steadyTextTertiary)
                
                Label(routine.targetMobilityLevel.rawValue, systemImage: "figure.stand")
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyTextSecondary)
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.steadyCardBackground)
        .cornerRadius(Theme.Radius.lg)
    }
    
    // MARK: - Quick Stats
    private var quickStats: some View {
        HStack(spacing: Theme.Spacing.md) {
            StatItem(
                value: "\(routine.exerciseIDs.count)",
                label: "Exercises",
                icon: "figure.walk"
            )
            
            StatItem(
                value: "\(Int(routine.estimatedDuration))",
                label: "Minutes",
                icon: "clock.fill"
            )
            
            StatItem(
                value: "\(routine.timesCompleted)",
                label: "Completed",
                icon: "checkmark.circle.fill"
            )
        }
    }
    
    // MARK: - Exercise List
    private var exerciseList: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Exercises")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            // Show sample exercises since we're using IDs
            ForEach(Array(sampleExercises.enumerated()), id: \.offset) { index, exercise in
                ExerciseListItem(exercise: exercise, index: index + 1)
            }
        }
    }
    
    // MARK: - Start Button
    private var startButton: some View {
        Button {
            showingWorkout = true
        } label: {
            Label("Start Routine", systemImage: "play.fill")
        }
        .buttonStyle(.primary)
        .padding(.vertical, Theme.Spacing.lg)
    }
    
    // Sample exercises for display
    private var sampleExercises: [Exercise] {
        Array(Exercise.sampleExercises.prefix(min(5, routine.exerciseIDs.count.nonZeroValue)))
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.steadyPrimary)
            
            Text(value)
                .font(Typography.headlineMedium)
                .foregroundColor(.steadyTextPrimary)
            
            Text(label)
                .font(Typography.caption)
                .foregroundColor(.steadyTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Color.steadyCardBackground)
        .cornerRadius(Theme.Radius.md)
    }
}

// MARK: - Exercise List Item
struct ExerciseListItem: View {
    let exercise: Exercise
    let index: Int
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Index
            Text("\(index)")
                .font(Typography.labelLarge)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.steadyPrimary)
                .clipShape(Circle())
            
            // Exercise info
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(exercise.name)
                    .font(Typography.labelLarge)
                    .foregroundColor(.steadyTextPrimary)
                
                Text("\(Int(exercise.duration)) seconds")
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextSecondary)
            }
            
            Spacer()
            
            // Category icon
            Image(systemName: exercise.category.icon)
                .foregroundColor(Color(hex: exercise.category.color))
        }
        .padding(Theme.Spacing.md)
        .background(Color.steadyCardBackground)
        .cornerRadius(Theme.Radius.md)
    }
}

// Helper extension
extension Int {
    var nonZeroValue: Int {
        self > 0 ? self : 5
    }
}

#Preview {
    NavigationStack {
        RoutineDetailView(routine: Routine.sampleRoutines[0])
    }
}
