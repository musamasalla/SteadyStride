//
//  ProgressView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData
import Charts

struct ProgressDashboardView: View {
    @State private var selectedTimeRange: TimeRange = .week
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
                AchievementsView()
            }
        }
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        HStack(spacing: Theme.Spacing.md) {
            ProgressStatCard(
                title: "This Week",
                value: "5",
                subtitle: "workouts",
                icon: "figure.walk",
                color: .steadyPrimary
            )
            
            ProgressStatCard(
                title: "Total Time",
                value: "45",
                subtitle: "minutes",
                icon: "clock.fill",
                color: .steadySecondary
            )
        }
    }
    
    // MARK: - Time Range Picker
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
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
            
            Chart {
                ForEach(sampleChartData, id: \.day) { data in
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
        .cardStyle()
    }
    
    // MARK: - Streak Section
    private var streakSection: some View {
        HStack(spacing: Theme.Spacing.lg) {
            VStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.steadySecondary)
                
                Text("7")
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
                
                Text("14")
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
                    AchievementBadge(type: .firstWorkout, isEarned: true)
                    AchievementBadge(type: .streak3Days, isEarned: true)
                    AchievementBadge(type: .streak7Days, isEarned: true)
                    AchievementBadge(type: .exercises10, isEarned: false)
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
                        .trim(from: 0, to: 0.75)
                        .stroke(Color.steadySuccess, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Text("75")
                        .font(Typography.headlineLarge)
                        .foregroundColor(.steadySuccess)
                }
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Low Risk")
                        .font(Typography.labelLarge)
                        .foregroundColor(.steadySuccess)
                    
                    Text("Your balance and mobility scores indicate a low fall risk. Keep up the great work!")
                        .font(Typography.bodySmall)
                        .foregroundColor(.steadyTextSecondary)
                }
            }
        }
        .cardStyle()
    }
    
    // Sample data
    private var sampleChartData: [ChartData] {
        [
            ChartData(day: "Mon", minutes: 15),
            ChartData(day: "Tue", minutes: 10),
            ChartData(day: "Wed", minutes: 20),
            ChartData(day: "Thu", minutes: 0),
            ChartData(day: "Fri", minutes: 12),
            ChartData(day: "Sat", minutes: 18),
            ChartData(day: "Sun", minutes: 8)
        ]
    }
}

struct ChartData {
    let day: String
    let minutes: Int
}

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.lg) {
                    ForEach(AchievementType.allCases, id: \.self) { type in
                        AchievementBadge(type: type, isEarned: [.firstWorkout, .streak3Days, .streak7Days].contains(type))
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
