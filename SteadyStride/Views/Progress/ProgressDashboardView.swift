//
//  ProgressDashboardView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData
import Charts

struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProgressViewModel()
    @State private var showingAchievements = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Overview Cards
                    overviewSection
                    
                    // Time Range Picker
                    timeRangePicker
                    
                    // Activity Chart
                    activityChartSection
                    
                    // Streak Section
                    streakSection
                    
                    // Achievements Preview
                    achievementsPreview
                    
                    // Fall Risk
                    fallRiskSection
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xxl)
            }
            .background(Color.steadyBackground)
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAchievements = true
                    } label: {
                        Image(systemName: "medal.fill")
                            .foregroundColor(.steadyWarning)
                    }
                }
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(earnedAchievements: viewModel.earnedAchievements)
            }
            .task {
                viewModel.loadProgressData(modelContext: modelContext)
                viewModel.updateFallRiskAssessment()
            }
            .refreshable {
                viewModel.loadProgressData(modelContext: modelContext)
                viewModel.updateFallRiskAssessment()
            }
        }
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        HStack(spacing: Theme.Spacing.md) {
            ProgressStatCard(
                title: "This Week",
                value: "\(weeklyWorkoutCount)",
                subtitle: "workouts",
                icon: "figure.walk",
                color: .steadyPrimary
            )
            
            ProgressStatCard(
                title: "Total Time",
                value: "\(weeklyMinutes)",
                subtitle: "minutes",
                icon: "clock.fill",
                color: .steadySecondary
            )
        }
    }
    
    private var weeklyWorkoutCount: Int {
        viewModel.weeklyData.reduce(0) { $0 + $1.workoutCount }
    }
    
    private var weeklyMinutes: Int {
        viewModel.weeklyData.reduce(0) { $0 + $1.minutes }
    }
    
    // MARK: - Time Range Picker
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $viewModel.selectedTimeRange) {
            ForEach(ProgressTimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Activity Chart
    private var activityChartSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Activity")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            if viewModel.weeklyData.isEmpty {
                ContentUnavailableView(
                    "No Data Yet",
                    systemImage: "chart.bar",
                    description: Text("Complete your first workout to see activity data")
                )
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(viewModel.weeklyData) { data in
                        BarMark(
                            x: .value("Day", data.day),
                            y: .value("Minutes", data.minutes)
                        )
                        .foregroundStyle(Color.steadyGradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .cardStyle()
    }
    
    // MARK: - Streak Section
    private var streakSection: some View {
        HStack(spacing: Theme.Spacing.lg) {
            VStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.steadySecondary)
                
                Text("\(viewModel.currentStreak)")
                    .font(Typography.displayMedium)
                    .foregroundColor(.steadyTextPrimary)
                
                Text("Day Streak")
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyTextSecondary)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 80)
            
            VStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.steadyWarning)
                
                Text("\(viewModel.bestStreak)")
                    .font(Typography.displayMedium)
                    .foregroundColor(.steadyTextPrimary)
                
                Text("Best Streak")
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .cardStyle()
    }
    
    // MARK: - Achievements Preview
    private var achievementsPreview: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Recent Achievements")
                    .font(Typography.headlineSmall)
                    .foregroundColor(.steadyTextPrimary)
                
                Spacer()
                
                Button("See All") {
                    showingAchievements = true
                }
                .font(Typography.labelMedium)
                .foregroundColor(.steadyPrimary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    ForEach(AchievementType.allCases.prefix(4), id: \.self) { type in
                        AchievementBadge(
                            type: type,
                            isEarned: viewModel.earnedAchievements.contains(type)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Fall Risk Section
    private var fallRiskSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Fall Risk Assessment")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            HStack(spacing: Theme.Spacing.lg) {
                ZStack {
                    Circle()
                        .stroke(Color.steadyBorder, lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: Double(viewModel.fallRiskScore) / 100.0)
                        .stroke(viewModel.fallRiskLevel.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(viewModel.fallRiskScore)")
                        .font(Typography.headlineLarge)
                        .foregroundColor(viewModel.fallRiskLevel.color)
                }
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(viewModel.fallRiskLevel.rawValue)
                        .font(Typography.labelLarge)
                        .foregroundColor(viewModel.fallRiskLevel.color)
                    
                    Text(viewModel.fallRiskLevel.description)
                        .font(Typography.bodySmall)
                        .foregroundColor(.steadyTextSecondary)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Progress Stat Card
struct ProgressStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(Typography.labelSmall)
                    .foregroundColor(.steadyTextSecondary)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: Theme.Spacing.xxs) {
                Text(value)
                    .font(Typography.displayMedium)
                    .foregroundColor(.steadyTextPrimary)
                
                Text(subtitle)
                    .font(Typography.bodySmall)
                    .foregroundColor(.steadyTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let type: AchievementType
    let isEarned: Bool
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            ZStack {
                Circle()
                    .fill(isEarned ? Color(hex: type.color).opacity(0.15) : Color.steadyBorder)
                    .frame(width: 60, height: 60)
                
                Image(systemName: type.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isEarned ? Color(hex: type.color) : .steadyTextTertiary)
            }
            
            Text(type.title)
                .font(Typography.caption)
                .foregroundColor(isEarned ? .steadyTextPrimary : .steadyTextTertiary)
                .lineLimit(1)
        }
        .frame(width: 80)
        .opacity(isEarned ? 1 : 0.5)
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    let earnedAchievements: [AchievementType]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.lg) {
                    ForEach(AchievementType.allCases, id: \.self) { type in
                        AchievementBadge(type: type, isEarned: earnedAchievements.contains(type))
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Color.steadyBackground)
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ProgressDashboardView()
}
