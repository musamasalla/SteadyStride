//
//  ProgressViewModel.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class ProgressViewModel {
    
    // MARK: - State
    var isLoading: Bool = false
    var selectedTimeRange: ProgressTimeRange = .week
    
    // MARK: - Stats
    var totalWorkouts: Int = 0
    var totalMinutes: Int = 0
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var averageSessionDuration: TimeInterval = 0
    var exercisesCompleted: Int = 0
    
    // MARK: - Charts Data
    var weeklyData: [DayActivityData] = []
    var monthlyData: [WeekActivityData] = []
    
    // MARK: - Achievements
    var earnedAchievements: [AchievementType] = []
    var recentAchievement: AchievementType?
    
    // MARK: - Fall Risk
    var fallRiskScore: Int = 75
    var fallRiskLevel: FallRiskLevel = .low
    
    // MARK: - Load Data
    func loadProgressData(modelContext: ModelContext) {
        isLoading = true
        
        // Fetch workout sessions
        let descriptor = FetchDescriptor<WorkoutSession>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        let sessions = (try? modelContext.fetch(descriptor)) ?? []
        let completedSessions = sessions.filter { $0.status == .completed }
        
        // Calculate stats
        totalWorkouts = completedSessions.count
        totalMinutes = Int(completedSessions.reduce(0) { $0 + $1.actualDuration } / 60)
        exercisesCompleted = completedSessions.reduce(0) { $0 + $1.completedExerciseIDs.count }
        
        if !completedSessions.isEmpty {
            averageSessionDuration = completedSessions.reduce(0) { $0 + $1.actualDuration } / Double(completedSessions.count)
        }
        
        // Calculate streaks
        calculateStreaks(from: completedSessions)
        
        // Generate chart data
        generateWeeklyData(from: completedSessions)
        generateMonthlyData(from: completedSessions)
        
        // Check achievements
        checkAchievements()
        
        isLoading = false
    }
    
    // MARK: - Streak Calculation
    private func calculateStreaks(from sessions: [WorkoutSession]) {
        let calendar = Calendar.current
        let sortedDates = sessions
            .map { calendar.startOfDay(for: $0.startTime) }
            .sorted(by: >)
        
        guard !sortedDates.isEmpty else {
            currentStreak = 0
            bestStreak = 0
            return
        }
        
        var streak = 1
        var maxStreak = 1
        var previousDate = sortedDates[0]
        
        // Check if today or yesterday has a workout
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if sortedDates[0] < yesterday {
            currentStreak = 0
        } else {
            for i in 1..<sortedDates.count {
                let currentDate = sortedDates[i]
                let dayDiff = calendar.dateComponents([.day], from: currentDate, to: previousDate).day ?? 0
                
                if dayDiff == 1 {
                    streak += 1
                    maxStreak = max(maxStreak, streak)
                } else if dayDiff > 1 {
                    break
                }
                previousDate = currentDate
            }
            currentStreak = streak
        }
        
        bestStreak = max(maxStreak, currentStreak)
    }
    
    // MARK: - Chart Data Generation
    private func generateWeeklyData(from sessions: [WorkoutSession]) {
        let calendar = Calendar.current
        let today = Date()
        
        weeklyData = (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let daySessions = sessions.filter { $0.startTime >= dayStart && $0.startTime < dayEnd }
            let minutes = Int(daySessions.reduce(0) { $0 + $1.actualDuration } / 60)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            
            return DayActivityData(
                day: formatter.string(from: date),
                date: date,
                minutes: minutes,
                workoutCount: daySessions.count
            )
        }
    }
    
    private func generateMonthlyData(from sessions: [WorkoutSession]) {
        let calendar = Calendar.current
        let today = Date()
        
        monthlyData = (0..<4).reversed().map { weeksAgo in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: today)!
            let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
            
            let weekSessions = sessions.filter { $0.startTime >= weekStart && $0.startTime < weekEnd }
            let minutes = Int(weekSessions.reduce(0) { $0 + $1.actualDuration } / 60)
            
            return WeekActivityData(
                weekNumber: weeksAgo == 0 ? "This Week" : "\(weeksAgo)w ago",
                startDate: weekStart,
                totalMinutes: minutes,
                workoutCount: weekSessions.count
            )
        }
    }
    
    // MARK: - Achievements
    private func checkAchievements() {
        earnedAchievements = []
        
        // First workout
        if totalWorkouts >= 1 {
            earnedAchievements.append(.firstWorkout)
        }
        
        // Streak achievements
        if currentStreak >= 3 {
            earnedAchievements.append(.streak3Days)
        }
        if currentStreak >= 7 {
            earnedAchievements.append(.streak7Days)
        }
        if currentStreak >= 30 {
            earnedAchievements.append(.streak30Days)
        }
        
        // Exercise count achievements
        if exercisesCompleted >= 10 {
            earnedAchievements.append(.exercises10)
        }
        if exercisesCompleted >= 50 {
            earnedAchievements.append(.exercises50)
        }
        if exercisesCompleted >= 100 {
            earnedAchievements.append(.exercises100)
        }
        
        // Time achievements
        if totalMinutes >= 60 {
            earnedAchievements.append(.minutes60)
        }
        if totalMinutes >= 300 {
            earnedAchievements.append(.minutes300)
        }
    }
    
    // MARK: - Fall Risk Assessment
    func updateFallRiskAssessment() {
        // In production, this would use HealthKit walking steadiness data
        // and workout completion rates to calculate a risk score
        
        var score = 50
        
        // Add points for consistency
        if currentStreak >= 7 { score += 15 }
        else if currentStreak >= 3 { score += 10 }
        else if currentStreak >= 1 { score += 5 }
        
        // Add points for total workouts
        if totalWorkouts >= 20 { score += 15 }
        else if totalWorkouts >= 10 { score += 10 }
        else if totalWorkouts >= 5 { score += 5 }
        
        // Add points for balance exercises
        // (In production, filter by category)
        score += min(10, exercisesCompleted / 5)
        
        fallRiskScore = min(100, score)
        fallRiskLevel = FallRiskLevel.level(for: fallRiskScore)
    }
}

// MARK: - Supporting Types
enum ProgressTimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct DayActivityData: Identifiable {
    let id = UUID()
    let day: String
    let date: Date
    let minutes: Int
    let workoutCount: Int
}

struct WeekActivityData: Identifiable {
    let id = UUID()
    let weekNumber: String
    let startDate: Date
    let totalMinutes: Int
    let workoutCount: Int
}

enum FallRiskLevel: String {
    case low = "Low Risk"
    case moderate = "Moderate Risk"
    case high = "High Risk"
    
    var color: Color {
        switch self {
        case .low: return .steadySuccess
        case .moderate: return .steadyWarning
        case .high: return .steadyError
        }
    }
    
    var description: String {
        switch self {
        case .low:
            return "Your balance and mobility scores indicate a low fall risk. Keep up the great work!"
        case .moderate:
            return "Your scores suggest some room for improvement. Regular exercise can help reduce risk."
        case .high:
            return "Consider focusing on balance exercises and consult with your healthcare provider."
        }
    }
    
    static func level(for score: Int) -> FallRiskLevel {
        switch score {
        case 70...: return .low
        case 40..<70: return .moderate
        default: return .high
        }
    }
}
