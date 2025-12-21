//
//  RoutinesView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData

struct RoutinesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Routine.name) private var allRoutines: [Routine]
    @State private var selectedCategory: ExerciseCategory?
    
    var initialCategory: ExerciseCategory?
    
    init(initialCategory: ExerciseCategory? = nil) {
        self.initialCategory = initialCategory
        _selectedCategory = State(initialValue: initialCategory)
    }
    
    private var routines: [Routine] {
        // First try database routines
        let dbRoutines = allRoutines.filter { routine in
            if let category = selectedCategory {
                return routine.category == category
            }
            return true
        }
        
        // If no database routines, use sample routines
        if dbRoutines.isEmpty {
            return Routine.sampleRoutines.filter { routine in
                if let category = selectedCategory {
                    return routine.category == category
                }
                return true
            }
        }
        
        return dbRoutines
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Category Filter
                categoryFilter
                
                // Routines List
                if routines.isEmpty {
                    ContentUnavailableView(
                        "No Routines",
                        systemImage: "figure.walk",
                        description: Text("No routines available for this category")
                    )
                    .padding(.top, Theme.Spacing.xxl)
                } else {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        ForEach(routines) { routine in
                            NavigationLink {
                                RoutineDetailView(routine: routine)
                            } label: {
                                RoutineCard(routine: routine)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
        }
        .background(Color.steadyBackground)
        .navigationTitle(selectedCategory?.rawValue ?? "Routines")
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                CategoryChip(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(ExerciseCategory.allCases) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.xs)
        }
    }
}

// MARK: - Routine Card
struct RoutineCard: View {
    let routine: Routine
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                // Category badge
                ZStack {
                    Circle()
                        .fill(Color(hex: routine.category.color).opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: routine.category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: routine.category.color))
                }
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    HStack {
                        Text(routine.name)
                            .font(Typography.labelLarge)
                            .foregroundColor(.steadyTextPrimary)
                        
                        if routine.isRecommended {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.steadyWarning)
                        }
                    }
                    
                    Text(routine.routineDescription)
                        .font(Typography.bodySmall)
                        .foregroundColor(.steadyTextSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.steadyTextTertiary)
            }
            
            // Stats row
            HStack(spacing: Theme.Spacing.lg) {
                Label("\(Int(routine.estimatedDuration)) min", systemImage: "clock")
                Label("\(routine.exerciseIDs.count > 0 ? routine.exerciseIDs.count : 5) exercises", systemImage: "figure.walk")
                DifficultyBadge(difficulty: routine.difficulty)
            }
            .font(Typography.caption)
            .foregroundColor(.steadyTextSecondary)
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .fill(Color.steadyCardBackground)
        )
        .shadowStyle(Theme.Shadow.sm)
    }
}

#Preview {
    NavigationStack {
        RoutinesView(initialCategory: .balance)
    }
}
