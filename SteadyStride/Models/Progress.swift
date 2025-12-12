//
//  Progress.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftData

// MARK: - Progress Entry Model
@Model
final class ProgressEntry {
    var id: UUID
    var date: Date
    var userID: UUID
    
    // Daily Stats
    var workoutsCompleted: Int
    var totalMinutes: Int
    var exercisesCompleted: Int
    var caloriesBurned: Double
    
    // Streak
    var streakDay: Int
    var isStreakContinued: Bool
    
    // Health Metrics (from HealthKit)
    var steps: Int?
    var averageHeartRate: Double?
    var activeMinutes: Int?
    
    // Self-reported
    var painLevel: Int? // 0-10
    var energyLevel: Int? // 1-5
    var balanceConfidence: Int? // 1-5
    var mood: SessionMood?
    
    // Goals
    var dailyGoalMet: Bool
    var weeklyGoalProgress: Double // 0.0 to 1.0
    
    init(userID: UUID, date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.userID = userID
        self.workoutsCompleted = 0
        self.totalMinutes = 0
        self.exercisesCompleted = 0
        self.caloriesBurned = 0
        self.streakDay = 0
        self.isStreakContinued = false
        self.dailyGoalMet = false
        self.weeklyGoalProgress = 0
    }
}

// MARK: - Achievement Model
@Model
final class Achievement {
    var id: UUID
    var type: AchievementType
    var title: String
    var achievementDescription: String
    var iconName: String
    var earnedDate: Date?
    var isEarned: Bool
    var progress: Double // 0.0 to 1.0
    var targetValue: Int
    var currentValue: Int
    
    init(type: AchievementType) {
        self.id = UUID()
        self.type = type
        self.title = type.title
        self.achievementDescription = type.description
        self.iconName = type.iconName
        self.isEarned = false
        self.progress = 0
        self.targetValue = type.targetValue
        self.currentValue = 0
    }
}

// MARK: - Achievement Type
enum AchievementType: String, Codable, CaseIterable {
    // Streak Achievements
    case firstWorkout = "first_workout"
    case streak3Days = "streak_3"
    case streak7Days = "streak_7"
    case streak14Days = "streak_14"
    case streak30Days = "streak_30"
    case streak100Days = "streak_100"
    
    // Exercise Achievements
    case exercises10 = "exercises_10"
    case exercises50 = "exercises_50"
    case exercises100 = "exercises_100"
    case exercises500 = "exercises_500"
    
    // Time Achievements
    case minutes30 = "minutes_30"
    case minutes60 = "minutes_60"
    case minutes300 = "minutes_300"
    case minutes1000 = "minutes_1000"
    
    // Category Achievements
    case balanceMaster = "balance_master"
    case strengthBuilder = "strength_builder"
    case flexibilityChamp = "flexibility_champ"
    case fallPreventer = "fall_preventer"
    
    // Special Achievements
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    case weekendWarrior = "weekend_warrior"
    case consistentChamp = "consistent_champ"
    case familyMotivator = "family_motivator"
    
    var title: String {
        switch self {
        case .firstWorkout: return "First Steps"
        case .streak3Days: return "Getting Started"
        case .streak7Days: return "Week Warrior"
        case .streak14Days: return "Two Week Triumph"
        case .streak30Days: return "Month of Motion"
        case .streak100Days: return "Century Club"
        case .exercises10: return "Exercise Explorer"
        case .exercises50: return "Exercise Enthusiast"
        case .exercises100: return "Exercise Expert"
        case .exercises500: return "Exercise Legend"
        case .minutes30: return "Half Hour Hero"
        case .minutes60: return "Hour of Power"
        case .minutes300: return "Dedicated Mover"
        case .minutes1000: return "Time Champion"
        case .balanceMaster: return "Balance Master"
        case .strengthBuilder: return "Strength Builder"
        case .flexibilityChamp: return "Flexibility Champion"
        case .fallPreventer: return "Fall Preventer"
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        case .weekendWarrior: return "Weekend Warrior"
        case .consistentChamp: return "Consistency Champion"
        case .familyMotivator: return "Family Motivator"
        }
    }
    
    var description: String {
        switch self {
        case .firstWorkout: return "Complete your first workout"
        case .streak3Days: return "Exercise for 3 days in a row"
        case .streak7Days: return "Keep a 7-day streak"
        case .streak14Days: return "Maintain a 14-day streak"
        case .streak30Days: return "Achieve a 30-day streak"
        case .streak100Days: return "Reach an incredible 100-day streak"
        case .exercises10: return "Complete 10 exercises"
        case .exercises50: return "Complete 50 exercises"
        case .exercises100: return "Complete 100 exercises"
        case .exercises500: return "Complete 500 exercises"
        case .minutes30: return "Exercise for 30 total minutes"
        case .minutes60: return "Exercise for 1 total hour"
        case .minutes300: return "Exercise for 5 total hours"
        case .minutes1000: return "Exercise for over 16 hours"
        case .balanceMaster: return "Complete 20 balance exercises"
        case .strengthBuilder: return "Complete 20 strength exercises"
        case .flexibilityChamp: return "Complete 20 flexibility exercises"
        case .fallPreventer: return "Complete 20 fall prevention exercises"
        case .earlyBird: return "Complete 5 workouts before 8 AM"
        case .nightOwl: return "Complete 5 workouts after 7 PM"
        case .weekendWarrior: return "Exercise every weekend for a month"
        case .consistentChamp: return "Never miss your scheduled workout for 2 weeks"
        case .familyMotivator: return "Share progress with family 10 times"
        }
    }
    
    var iconName: String {
        switch self {
        case .firstWorkout: return "star.fill"
        case .streak3Days: return "flame.fill"
        case .streak7Days: return "flame.fill"
        case .streak14Days: return "flame.fill"
        case .streak30Days: return "flame.circle.fill"
        case .streak100Days: return "crown.fill"
        case .exercises10: return "figure.walk"
        case .exercises50: return "figure.run"
        case .exercises100: return "figure.strengthtraining.traditional"
        case .exercises500: return "medal.fill"
        case .minutes30: return "clock.fill"
        case .minutes60: return "clock.badge.checkmark.fill"
        case .minutes300: return "timer"
        case .minutes1000: return "hourglass.badge.plus"
        case .balanceMaster: return "figure.stand"
        case .strengthBuilder: return "dumbbell.fill"
        case .flexibilityChamp: return "figure.flexibility"
        case .fallPreventer: return "shield.checkered"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.stars.fill"
        case .weekendWarrior: return "calendar.badge.checkmark"
        case .consistentChamp: return "checkmark.seal.fill"
        case .familyMotivator: return "heart.circle.fill"
        }
    }
    
    var targetValue: Int {
        switch self {
        case .firstWorkout: return 1
        case .streak3Days: return 3
        case .streak7Days: return 7
        case .streak14Days: return 14
        case .streak30Days: return 30
        case .streak100Days: return 100
        case .exercises10: return 10
        case .exercises50: return 50
        case .exercises100: return 100
        case .exercises500: return 500
        case .minutes30: return 30
        case .minutes60: return 60
        case .minutes300: return 300
        case .minutes1000: return 1000
        case .balanceMaster: return 20
        case .strengthBuilder: return 20
        case .flexibilityChamp: return 20
        case .fallPreventer: return 20
        case .earlyBird: return 5
        case .nightOwl: return 5
        case .weekendWarrior: return 8
        case .consistentChamp: return 14
        case .familyMotivator: return 10
        }
    }
    
    var color: String {
        switch self {
        case .firstWorkout: return "FFB703"
        case .streak3Days, .streak7Days, .streak14Days: return "E76F51"
        case .streak30Days, .streak100Days: return "EF476F"
        case .exercises10, .exercises50, .exercises100, .exercises500: return "2A9D8F"
        case .minutes30, .minutes60, .minutes300, .minutes1000: return "118AB2"
        case .balanceMaster, .strengthBuilder, .flexibilityChamp, .fallPreventer: return "06D6A0"
        case .earlyBird, .nightOwl, .weekendWarrior, .consistentChamp: return "9B5DE5"
        case .familyMotivator: return "F15BB5"
        }
    }
}

// MARK: - Weekly Summary
struct WeeklySummary: Identifiable {
    let id = UUID()
    let weekStartDate: Date
    let workoutsCompleted: Int
    let totalMinutes: Int
    let exercisesCompleted: Int
    let averagePainLevel: Double?
    let streakDays: Int
    let goalsMet: Int
    let totalGoals: Int
    
    var completionRate: Double {
        guard totalGoals > 0 else { return 0 }
        return Double(goalsMet) / Double(totalGoals)
    }
    
    var weekLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) ?? weekStartDate
        return "\(formatter.string(from: weekStartDate)) - \(formatter.string(from: endDate))"
    }
}

// MARK: - Fall Risk Assessment
struct FallRiskAssessment: Identifiable, Codable {
    let id: UUID
    let date: Date
    let score: Int // 0-100, higher is better (lower risk)
    let category: FallRiskCategory
    let factors: [FallRiskFactor]
    let recommendations: [String]
    
    init(score: Int, factors: [FallRiskFactor]) {
        self.id = UUID()
        self.date = Date()
        self.score = score
        self.category = FallRiskCategory.fromScore(score)
        self.factors = factors
        self.recommendations = category.recommendations
    }
}

enum FallRiskCategory: String, Codable {
    case low = "Low Risk"
    case moderate = "Moderate Risk"
    case high = "High Risk"
    
    var color: String {
        switch self {
        case .low: return "06D6A0"
        case .moderate: return "FFB703"
        case .high: return "EF476F"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "checkmark.shield.fill"
        case .moderate: return "exclamationmark.shield.fill"
        case .high: return "exclamationmark.triangle.fill"
        }
    }
    
    var recommendations: [String] {
        switch self {
        case .low:
            return [
                "Continue your current exercise routine",
                "Focus on maintaining balance and strength",
                "Stay active and mobile throughout the day"
            ]
        case .moderate:
            return [
                "Increase balance exercise frequency",
                "Review home safety with family",
                "Consider using support when needed",
                "Speak with your doctor about fall prevention"
            ]
        case .high:
            return [
                "Consult your healthcare provider immediately",
                "Use assistive devices as recommended",
                "Have a family member assist with exercises",
                "Review medications with your doctor",
                "Consider a formal fall risk assessment"
            ]
        }
    }
    
    static func fromScore(_ score: Int) -> FallRiskCategory {
        switch score {
        case 70...100: return .low
        case 40..<70: return .moderate
        default: return .high
        }
    }
}

struct FallRiskFactor: Codable, Identifiable {
    let id: UUID
    let name: String
    let severity: Int // 1-3
    let isModifiable: Bool
    
    init(name: String, severity: Int, isModifiable: Bool) {
        self.id = UUID()
        self.name = name
        self.severity = severity
        self.isModifiable = isModifiable
    }
}
