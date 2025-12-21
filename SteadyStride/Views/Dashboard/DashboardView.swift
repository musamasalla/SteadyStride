//
//  DashboardView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()
    @State private var showingWorkout: Bool = false
    @State private var showingActivityHistory: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Header
                    headerSection
                    
                    // Today's Workout Card
                    todayWorkoutCard
                    
                    // Stats Row
                    statsRow
                    
                    // Weekly Progress
                    weeklyProgressSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Activity
                    recentActivitySection
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xxl)
            }
            .background(Color.steadyBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.steadyTextSecondary)
                    }
                }
            }
            .refreshable {
                await viewModel.loadDashboardData(modelContext: modelContext)
            }
            .task {
                await viewModel.loadDashboardData(modelContext: modelContext)
            }
            .fullScreenCover(isPresented: $showingWorkout) {
                if let routine = viewModel.todayWorkout {
                    WorkoutSessionView(routine: routine)
                }
            }
            .sheet(isPresented: $showingActivityHistory) {
                NavigationStack {
                    ActivityHistoryView()
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(viewModel.greeting)
                .font(Typography.headlineMedium)
                .foregroundColor(.steadyTextSecondary)
            
            Text("Ready to move?")
                .font(Typography.displaySmall)
                .foregroundColor(.steadyTextPrimary)
            
            Text(viewModel.motivationalMessage)
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Theme.Spacing.md)
    }
    
    // MARK: - Today's Workout Card
    private var todayWorkoutCard: some View {
        Button {
            showingWorkout = true
        } label: {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("TODAY'S WORKOUT")
                            .font(Typography.overline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(viewModel.todayWorkout?.name ?? "Morning Balance Boost")
                            .font(Typography.headlineLarge)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: Theme.Spacing.lg) {
                    Label("\(Int(viewModel.todayWorkout?.estimatedDuration ?? 10)) min", systemImage: "clock")
                    Label("\(viewModel.todayWorkout?.difficulty.rawValue ?? "Easy")", systemImage: "flame")
                }
                .font(Typography.labelMedium)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.xl)
                    .fill(Color.steadyGradient)
            )
            .shadowStyle(Theme.Shadow.lg)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: Theme.Spacing.md) {
            StatCard(
                title: "Steps",
                value: "\(viewModel.todaySteps)",
                icon: "figure.walk",
                color: .steadyPrimary
            )
            
            StatCard(
                title: "Active",
                value: "\(viewModel.todayActiveMinutes)m",
                icon: "flame.fill",
                color: .steadySecondary
            )
            
            StatCard(
                title: "Streak",
                value: "\(viewModel.currentStreak)",
                icon: "bolt.fill",
                color: .steadySuccess
            )
        }
    }
    
    // MARK: - Weekly Progress
    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("This Week")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    WeekDayIndicator(
                        day: day.initial,
                        isCompleted: viewModel.weeklyProgress[Date()] ?? false,
                        isToday: true
                    )
                }
            }
        }
        .cardStyle()
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Quick Start")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    NavigationLink {
                        RoutinesView(initialCategory: .balance)
                    } label: {
                        QuickActionCard(
                            title: "Balance",
                            icon: "figure.stand",
                            color: .steadyPrimary
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        RoutinesView(initialCategory: .strength)
                    } label: {
                        QuickActionCard(
                            title: "Strength",
                            icon: "dumbbell.fill",
                            color: .steadySecondary
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        RoutinesView(initialCategory: .flexibility)
                    } label: {
                        QuickActionCard(
                            title: "Flexibility",
                            icon: "figure.flexibility",
                            color: .steadySuccess
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        RoutinesView(initialCategory: .breathing)
                    } label: {
                        QuickActionCard(
                            title: "Breathing",
                            icon: "wind",
                            color: .steadyInfo
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Recent Activity
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Recent Activity")
                    .font(Typography.headlineSmall)
                    .foregroundColor(.steadyTextPrimary)
                
                Spacer()
                
                Button("See All") {
                    showingActivityHistory = true
                }
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyPrimary)
            }
            
            if viewModel.recentSessions.isEmpty {
                EmptyActivityCard()
            } else {
                ForEach(viewModel.recentSessions.prefix(3)) { session in
                    RecentActivityRow(session: session)
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(Typography.headlineLarge)
                .foregroundColor(.steadyTextPrimary)
            
            Text(title)
                .font(Typography.caption)
                .foregroundColor(.steadyTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .fill(Color.steadyCardBackground)
        )
        .shadowStyle(Theme.Shadow.sm)
    }
}

struct WeekDayIndicator: View {
    let day: String
    let isCompleted: Bool
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(day)
                .font(Typography.caption)
                .foregroundColor(.steadyTextSecondary)
            
            Circle()
                .fill(isCompleted ? Color.steadySuccess : Color.steadyBorder)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(isToday ? Color.steadyPrimary : Color.clear, lineWidth: 2)
                )
                .overlay(
                    isCompleted ? Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    : nil
                )
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(title)
                .font(Typography.labelSmall)
                .foregroundColor(.steadyTextPrimary)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .fill(Color.steadyCardBackground)
        )
        .shadowStyle(Theme.Shadow.sm)
    }
}

struct EmptyActivityCard: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "figure.walk.motion")
                .font(.system(size: 40))
                .foregroundColor(.steadyTextTertiary)
            
            Text("No recent activity")
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextSecondary)
            
            Text("Complete your first workout to see it here")
                .font(Typography.bodySmall)
                .foregroundColor(.steadyTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .fill(Color.steadyBackgroundSecondary)
        )
    }
}

struct RecentActivityRow: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Circle()
                .fill(Color.steadyPrimaryLight)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.steadyPrimary)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.routineName)
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyTextPrimary)
                
                Text(session.formattedDate)
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextSecondary)
            }
            
            Spacer()
            
            Text(session.formattedDuration)
                .font(Typography.labelMedium)
                .foregroundColor(.steadyTextSecondary)
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.md)
                .fill(Color.steadyCardBackground)
        )
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [User.self, WorkoutSession.self], inMemory: true)
}
