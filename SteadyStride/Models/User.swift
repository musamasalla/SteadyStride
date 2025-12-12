//
//  User.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftData

// MARK: - User Model
@Model
final class User {
    var id: UUID
    var name: String
    var email: String?
    var age: Int
    var dateOfBirth: Date?
    var profileImageData: Data?
    
    // Health & Mobility
    var mobilityLevel: MobilityLevel
    var healthGoals: [HealthGoal]
    var healthConditions: [String]
    var doctorNotes: String?
    
    // Preferences
    var preferredWorkoutTime: Date?
    var workoutReminderEnabled: Bool
    var voiceGuidanceEnabled: Bool
    var voiceSpeed: VoiceSpeed
    var hapticFeedbackEnabled: Bool
    
    // Subscription
    var subscriptionTier: SubscriptionTier
    var subscriptionExpiryDate: Date?
    
    // Progress
    var currentStreak: Int
    var longestStreak: Int
    var totalWorkoutsCompleted: Int
    var totalMinutesExercised: Int
    var joinDate: Date
    var lastWorkoutDate: Date?
    
    // Family
    @Relationship(deleteRule: .cascade) var familyMembers: [FamilyMember]?
    
    // Onboarding
    var hasCompletedOnboarding: Bool
    var hasConnectedWatch: Bool
    var hasGrantedHealthKitPermission: Bool
    
    init(
        name: String,
        age: Int,
        mobilityLevel: MobilityLevel = .beginner,
        healthGoals: [HealthGoal] = []
    ) {
        self.id = UUID()
        self.name = name
        self.age = age
        self.mobilityLevel = mobilityLevel
        self.healthGoals = healthGoals
        self.healthConditions = []
        self.workoutReminderEnabled = true
        self.voiceGuidanceEnabled = true
        self.voiceSpeed = .normal
        self.hapticFeedbackEnabled = true
        self.subscriptionTier = .free
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalWorkoutsCompleted = 0
        self.totalMinutesExercised = 0
        self.joinDate = Date()
        self.hasCompletedOnboarding = false
        self.hasConnectedWatch = false
        self.hasGrantedHealthKitPermission = false
    }
}

// MARK: - Mobility Level
enum MobilityLevel: String, Codable, CaseIterable {
    case beginner = "Just Starting"
    case intermediate = "Building Strength"
    case advanced = "Maintaining Fitness"
    
    var description: String {
        switch self {
        case .beginner:
            return "New to exercise or returning after a break"
        case .intermediate:
            return "Regularly active with room to grow"
        case .advanced:
            return "Active lifestyle, looking to maintain"
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "figure.walk"
        case .intermediate: return "figure.run"
        case .advanced: return "figure.strengthtraining.traditional"
        }
    }
    
    var color: String {
        switch self {
        case .beginner: return "06D6A0"
        case .intermediate: return "2A9D8F"
        case .advanced: return "E76F51"
        }
    }
}

// MARK: - Health Goals
enum HealthGoal: String, Codable, CaseIterable, Identifiable {
    case improveBalance = "Improve Balance"
    case preventFalls = "Prevent Falls"
    case buildStrength = "Build Strength"
    case increaseFlexibility = "Increase Flexibility"
    case improvePosture = "Improve Posture"
    case manageArthritis = "Manage Arthritis"
    case recoverFromSurgery = "Recover From Surgery"
    case stayIndependent = "Stay Independent"
    case reduceJointPain = "Reduce Joint Pain"
    case improveEnergy = "Improve Energy"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .improveBalance: return "figure.stand"
        case .preventFalls: return "figure.fall"
        case .buildStrength: return "figure.strengthtraining.traditional"
        case .increaseFlexibility: return "figure.flexibility"
        case .improvePosture: return "figure.stand.line.dotted.figure.stand"
        case .manageArthritis: return "hand.raised.fingers.spread"
        case .recoverFromSurgery: return "cross.case"
        case .stayIndependent: return "house"
        case .reduceJointPain: return "bandage"
        case .improveEnergy: return "bolt.fill"
        }
    }
    
    var description: String {
        switch self {
        case .improveBalance:
            return "Exercises to enhance stability and coordination"
        case .preventFalls:
            return "Targeted movements to reduce fall risk"
        case .buildStrength:
            return "Gentle strength training for daily activities"
        case .increaseFlexibility:
            return "Stretches to improve range of motion"
        case .improvePosture:
            return "Exercises for better alignment and posture"
        case .manageArthritis:
            return "Low-impact movements for joint health"
        case .recoverFromSurgery:
            return "Gradual exercises for rehabilitation"
        case .stayIndependent:
            return "Functional exercises for daily life"
        case .reduceJointPain:
            return "Gentle movements to ease discomfort"
        case .improveEnergy:
            return "Activities to boost vitality and mood"
        }
    }
}

// MARK: - Subscription Tier
enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "Free"
    case unlocked = "Full Access"
    case premium = "Premium Coach"
    
    var displayName: String { rawValue }
    
    var features: [String] {
        switch self {
        case .free:
            return [
                "5 exercises per day",
                "Basic voice guidance",
                "7-day progress history"
            ]
        case .unlocked:
            return [
                "Unlimited exercises",
                "Full voice coaching",
                "Complete progress history",
                "1 family member"
            ]
        case .premium:
            return [
                "Everything in Full Access",
                "Personalized AI coaching",
                "Unlimited family sharing",
                "Doctor-friendly reports",
                "Priority support"
            ]
        }
    }
    
    var monthlyPrice: String {
        switch self {
        case .free: return "Free"
        case .unlocked: return "$9.99 one-time"
        case .premium: return "$2.99/month"
        }
    }
}

// MARK: - Voice Speed
enum VoiceSpeed: String, Codable, CaseIterable {
    case slow = "Slow"
    case normal = "Normal"
    case fast = "Fast"
    
    var rate: Float {
        switch self {
        case .slow: return 0.4
        case .normal: return 0.5
        case .fast: return 0.6
        }
    }
}
