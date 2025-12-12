//
//  Routine.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftData

// MARK: - Routine Model
@Model
final class Routine {
    var id: UUID
    var name: String
    var routineDescription: String
    var category: ExerciseCategory
    var targetMobilityLevel: MobilityLevel
    var difficulty: Difficulty
    
    // Exercises - stored as IDs to reference Exercise objects
    var exerciseIDs: [UUID]
    
    // Timing
    var estimatedDuration: TimeInterval // in minutes
    var restBetweenExercises: TimeInterval // in seconds
    
    // Metadata
    var isPremium: Bool
    var isRecommended: Bool
    var thumbnailImageName: String?
    
    // Personalization
    var targetGoals: [HealthGoal]
    var suitableConditions: [String] // e.g., "arthritis-friendly", "chair-based"
    
    // Stats
    var timesCompleted: Int
    var averageRating: Double
    var isFavorite: Bool
    
    // Schedule
    var recommendedDays: [DayOfWeek]
    var recommendedTimeOfDay: TimeOfDay?
    
    init(
        name: String,
        description: String,
        category: ExerciseCategory,
        targetMobilityLevel: MobilityLevel,
        difficulty: Difficulty,
        exerciseIDs: [UUID] = [],
        estimatedDuration: TimeInterval = 15,
        isPremium: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.routineDescription = description
        self.category = category
        self.targetMobilityLevel = targetMobilityLevel
        self.difficulty = difficulty
        self.exerciseIDs = exerciseIDs
        self.estimatedDuration = estimatedDuration
        self.restBetweenExercises = 15
        self.isPremium = isPremium
        self.isRecommended = false
        self.targetGoals = []
        self.suitableConditions = []
        self.timesCompleted = 0
        self.averageRating = 0.0
        self.isFavorite = false
        self.recommendedDays = []
    }
}

// MARK: - Day of Week
enum DayOfWeek: String, Codable, CaseIterable, Identifiable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    
    var id: String { rawValue }
    
    var shortName: String {
        String(rawValue.prefix(3))
    }
    
    var initial: String {
        String(rawValue.prefix(1))
    }
}

// MARK: - Time of Day
enum TimeOfDay: String, Codable, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    
    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        }
    }
    
    var timeRange: String {
        switch self {
        case .morning: return "6 AM - 12 PM"
        case .afternoon: return "12 PM - 5 PM"
        case .evening: return "5 PM - 9 PM"
        }
    }
}

// MARK: - Sample Routines
extension Routine {
    static var sampleRoutines: [Routine] {
        [
            // Morning Balance Routine
            {
                let routine = Routine(
                    name: "Morning Balance Boost",
                    description: "Start your day with gentle balance exercises to wake up your body and improve stability.",
                    category: .balance,
                    targetMobilityLevel: .beginner,
                    difficulty: .easy,
                    estimatedDuration: 10,
                    isPremium: false
                )
                routine.isRecommended = true
                routine.targetGoals = [.improveBalance, .preventFalls]
                routine.recommendedDays = [.monday, .wednesday, .friday]
                routine.recommendedTimeOfDay = .morning
                routine.suitableConditions = ["beginner-friendly", "no-equipment"]
                return routine
            }(),
            
            // Fall Prevention Routine
            {
                let routine = Routine(
                    name: "Fall Prevention Essentials",
                    description: "Evidence-based exercises specifically designed to reduce your risk of falls.",
                    category: .fallPrevention,
                    targetMobilityLevel: .beginner,
                    difficulty: .easy,
                    estimatedDuration: 15,
                    isPremium: false
                )
                routine.isRecommended = true
                routine.targetGoals = [.preventFalls, .improveBalance, .buildStrength]
                routine.recommendedDays = [.tuesday, .thursday, .saturday]
                routine.suitableConditions = ["doctor-recommended", "chair-available"]
                return routine
            }(),
            
            // Gentle Strength
            {
                let routine = Routine(
                    name: "Gentle Strength Builder",
                    description: "Build functional strength for everyday activities like getting up from chairs and carrying groceries.",
                    category: .strength,
                    targetMobilityLevel: .intermediate,
                    difficulty: .moderate,
                    estimatedDuration: 20,
                    isPremium: true
                )
                routine.targetGoals = [.buildStrength, .stayIndependent]
                routine.recommendedDays = [.monday, .wednesday, .friday]
                routine.suitableConditions = ["uses-chair", "low-impact"]
                return routine
            }(),
            
            // Flexibility Flow
            {
                let routine = Routine(
                    name: "Flexibility Flow",
                    description: "Gentle stretches to improve range of motion and reduce stiffness.",
                    category: .flexibility,
                    targetMobilityLevel: .beginner,
                    difficulty: .easy,
                    estimatedDuration: 12,
                    isPremium: false
                )
                routine.targetGoals = [.increaseFlexibility, .reduceJointPain]
                routine.recommendedDays = DayOfWeek.allCases
                routine.recommendedTimeOfDay = .evening
                routine.suitableConditions = ["arthritis-friendly", "relaxing"]
                return routine
            }(),
            
            // Posture Perfect
            {
                let routine = Routine(
                    name: "Posture Perfect",
                    description: "Improve your posture and reduce back and neck discomfort with these targeted exercises.",
                    category: .posture,
                    targetMobilityLevel: .beginner,
                    difficulty: .easy,
                    estimatedDuration: 10,
                    isPremium: true
                )
                routine.targetGoals = [.improvePosture, .reduceJointPain]
                routine.recommendedDays = [.monday, .tuesday, .wednesday, .thursday, .friday]
                routine.suitableConditions = ["office-friendly", "no-equipment"]
                return routine
            }(),
            
            // Quick Energy Boost
            {
                let routine = Routine(
                    name: "Quick Energy Boost",
                    description: "A short routine to increase energy and improve mood through gentle movement.",
                    category: .warmup,
                    targetMobilityLevel: .beginner,
                    difficulty: .easy,
                    estimatedDuration: 5,
                    isPremium: false
                )
                routine.targetGoals = [.improveEnergy]
                routine.recommendedTimeOfDay = .afternoon
                routine.suitableConditions = ["quick", "energizing"]
                return routine
            }(),
            
            // Evening Wind Down
            {
                let routine = Routine(
                    name: "Evening Wind Down",
                    description: "Calming exercises and stretches to prepare your body for restful sleep.",
                    category: .cooldown,
                    targetMobilityLevel: .beginner,
                    difficulty: .easy,
                    estimatedDuration: 8,
                    isPremium: false
                )
                routine.targetGoals = [.increaseFlexibility]
                routine.recommendedTimeOfDay = .evening
                routine.suitableConditions = ["relaxing", "calming", "pre-sleep"]
                return routine
            }()
        ]
    }
}
