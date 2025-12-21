//
//  ExerciseLibraryView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory?
    @State private var selectedExercise: Exercise?
    
    private var exercises: [Exercise] {
        ExerciseDataService.shared.allExercises
    }
    
    private var filteredExercises: [Exercise] {
        var result = exercises
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Category Filter
                    categoryFilter
                    
                    // Exercise Grid
                    exerciseGrid
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
            .background(Color.steadyBackground)
            .navigationTitle("Exercises")
            .searchable(text: $searchText, prompt: "Search exercises")
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
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
    
    // MARK: - Exercise Grid
    private var exerciseGrid: some View {
        LazyVStack(spacing: Theme.Spacing.md) {
            ForEach(filteredExercises, id: \.id) { exercise in
                ExerciseCard(exercise: exercise) {
                    selectedExercise = exercise
                }
            }
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(Typography.labelSmall)
            }
            .foregroundColor(isSelected ? .white : .steadyTextSecondary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? Color.steadyPrimary : Color.steadyCardBackground)
            )
        }
    }
}

// MARK: - Exercise Card
struct ExerciseCard: View {
    let exercise: Exercise
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: exercise.category.color).opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: exercise.category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: exercise.category.color))
                }
                
                // Info
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    HStack {
                        Text(exercise.name)
                            .font(Typography.labelLarge)
                            .foregroundColor(.steadyTextPrimary)
                        
                        if exercise.isPremium {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.steadyWarning)
                        }
                    }
                    
                    Text(exercise.category.rawValue)
                        .font(Typography.caption)
                        .foregroundColor(.steadyTextSecondary)
                    
                    HStack(spacing: Theme.Spacing.md) {
                        Label("\(Int(exercise.duration))s", systemImage: "clock")
                        Label(exercise.difficulty.rawValue, systemImage: exercise.difficulty.icon)
                    }
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextTertiary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.steadyTextTertiary)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .fill(Color.steadyCardBackground)
            )
            .shadowStyle(Theme.Shadow.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Exercise Detail View
struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    @State private var showingWorkout = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header
                    headerSection
                    
                    // Instructions
                    instructionsSection
                    
                    // Benefits
                    benefitsSection
                    
                    // Tips
                    if !exercise.tips.isEmpty {
                        tipsSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Color.steadyBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        exercise.isFavorite.toggle()
                    } label: {
                        Image(systemName: exercise.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(exercise.isFavorite ? .steadyError : .steadyTextSecondary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                startButton
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: exercise.category.color).opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: exercise.category.icon)
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: exercise.category.color))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                    Label("\(Int(exercise.duration))s", systemImage: "clock")
                    Label(exercise.difficulty.rawValue, systemImage: exercise.difficulty.icon)
                }
                .font(Typography.labelMedium)
                .foregroundColor(.steadyTextSecondary)
            }
            
            Text(exercise.name)
                .font(Typography.displaySmall)
                .foregroundColor(.steadyTextPrimary)
            
            Text(exercise.exerciseDescription)
                .font(Typography.bodyLarge)
                .foregroundColor(.steadyTextSecondary)
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Instructions")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: Theme.Spacing.md) {
                        Text("\(index + 1)")
                            .font(Typography.labelMedium)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color.steadyPrimary))
                        
                        Text(instruction)
                            .font(Typography.bodyMedium)
                            .foregroundColor(.steadyTextSecondary)
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Benefits")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            FlowLayout(spacing: Theme.Spacing.sm) {
                ForEach(exercise.benefits, id: \.self) { benefit in
                    Text(benefit)
                        .font(Typography.labelSmall)
                        .foregroundColor(.steadyPrimary)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(Color.steadyPrimaryLight)
                        )
                }
            }
        }
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Tips")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            ForEach(exercise.tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.steadyWarning)
                    
                    Text(tip)
                        .font(Typography.bodyMedium)
                        .foregroundColor(.steadyTextSecondary)
                }
            }
        }
        .cardStyle()
    }
    
    private var startButton: some View {
        Button {
            showingWorkout = true
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Exercise")
            }
        }
        .buttonStyle(.primary)
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
        .background(Color.steadyBackground)
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        return (CGSize(width: maxWidth, height: currentY + lineHeight), frames)
    }
}

#Preview {
    ExerciseLibraryView()
}
