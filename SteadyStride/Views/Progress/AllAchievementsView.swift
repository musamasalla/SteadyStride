//
//  AchievementsView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

struct AllAchievementsView: View {
    @State private var earnedAchievements: [AchievementType] = [
        .firstWorkout, .streak3Days, .exercises10, .minutes30
    ]
    @State private var selectedAchievement: AchievementType?
    @State private var showingDetail: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Stats Header
                    statsHeader
                    
                    // Earned Achievements
                    achievementSection(
                        title: "Earned",
                        achievements: earnedAchievements,
                        isEarned: true
                    )
                    
                    // In Progress
                    achievementSection(
                        title: "In Progress",
                        achievements: inProgressAchievements,
                        isEarned: false
                    )
                    
                    // Locked
                    achievementSection(
                        title: "Locked",
                        achievements: lockedAchievements,
                        isEarned: false
                    )
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Color.steadyBackground)
            .navigationTitle("Achievements")
            .sheet(item: $selectedAchievement) { achievement in
                AchievementDetailSheet(achievement: achievement, isEarned: earnedAchievements.contains(achievement))
            }
        }
    }
    
    // MARK: - Stats Header
    private var statsHeader: some View {
        HStack(spacing: Theme.Spacing.lg) {
            StatBox(value: "\(earnedAchievements.count)", label: "Earned", icon: "medal.fill", color: .steadySecondary)
            StatBox(value: "\(inProgressAchievements.count)", label: "In Progress", icon: "hourglass", color: .steadyPrimary)
            StatBox(value: "\(lockedAchievements.count)", label: "Locked", icon: "lock.fill", color: .steadyTextTertiary)
        }
    }
    
    // MARK: - Achievement Section
    private func achievementSection(title: String, achievements: [AchievementType], isEarned: Bool) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(title)
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            if achievements.isEmpty {
                Text("No achievements yet")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.steadyTextTertiary)
                    .padding(.vertical, Theme.Spacing.lg)
            } else {
                LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                    ForEach(achievements, id: \.self) { achievement in
                        AchievementCard(
                            achievement: achievement,
                            isEarned: isEarned
                        )
                        .onTapGesture {
                            selectedAchievement = achievement
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Computed
    private var inProgressAchievements: [AchievementType] {
        [.streak7Days, .exercises50]
    }
    
    private var lockedAchievements: [AchievementType] {
        AchievementType.allCases.filter { 
            !earnedAchievements.contains($0) && !inProgressAchievements.contains($0)
        }
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(Typography.headlineLarge)
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

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: AchievementType
    let isEarned: Bool
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(isEarned ? Color(hex: achievement.color).opacity(0.2) : Color.steadyTextTertiary.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(isEarned ? Color(hex: achievement.color) : .steadyTextTertiary)
            }
            
            Text(achievement.title)
                .font(Typography.caption)
                .foregroundColor(isEarned ? .steadyTextPrimary : .steadyTextTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(Theme.Spacing.sm)
        .frame(maxWidth: .infinity)
        .background(Color.steadyCardBackground)
        .cornerRadius(Theme.Radius.md)
        .opacity(isEarned ? 1 : 0.6)
    }
}

// MARK: - Achievement Detail Sheet
struct AchievementDetailSheet: View {
    let achievement: AchievementType
    let isEarned: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Dismiss indicator
            Capsule()
                .fill(Color.steadyTextTertiary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, Theme.Spacing.md)
            
            // Icon
            ZStack {
                Circle()
                    .fill(isEarned ? Color(hex: achievement.color).opacity(0.2) : Color.steadyTextTertiary.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 50))
                    .foregroundColor(isEarned ? Color(hex: achievement.color) : .steadyTextTertiary)
            }
            
            // Title
            Text(achievement.title)
                .font(Typography.headlineLarge)
                .foregroundColor(.steadyTextPrimary)
            
            // Description
            Text(achievement.description)
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
            
            // Status
            if isEarned {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.steadySuccess)
                    Text("Earned!")
                        .font(Typography.labelLarge)
                        .foregroundColor(.steadySuccess)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .background(Color.steadySuccess.opacity(0.15))
                .cornerRadius(Theme.Radius.full)
            } else {
                VStack(spacing: Theme.Spacing.xs) {
                    Text("Progress: 0%")
                        .font(Typography.labelMedium)
                        .foregroundColor(.steadyTextSecondary)
                    
                    ProgressView(value: 0, total: 1)
                        .tint(Color(hex: achievement.color))
                        .frame(width: 200)
                }
            }
            
            Spacer()
            
            // Share button (if earned)
            if isEarned {
                Button {
                    // Share action
                } label: {
                    Label("Share with Family", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.primary)
                .padding(.horizontal, Theme.Spacing.xl)
            }
            
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.secondary)
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(Color.steadyBackground)
    }
}

extension AchievementType: Identifiable {
    var id: String { rawValue }
}

#Preview {
    AllAchievementsView()
}
