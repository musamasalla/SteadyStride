//
//  Exercise.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftData

// MARK: - Exercise Model
@Model
final class Exercise {
    var id: UUID
    var name: String
    var exerciseDescription: String
    var category: ExerciseCategory
    var difficulty: Difficulty
    var duration: TimeInterval // in seconds
    var restDuration: TimeInterval // recommended rest after
    
    // Instructions
    var instructions: [String]
    var tips: [String]
    var warnings: [String]
    
    // Benefits
    var benefits: [String]
    var targetMuscles: [String]
    
    // Media
    var thumbnailImageName: String?
    var videoFileName: String?
    var animationName: String?
    
    // Metadata
    var isPremium: Bool
    var equipmentNeeded: [Equipment]
    var modifications: [ExerciseModification]
    
    // Voice Guidance
    var voiceInstructions: [VoiceInstruction]
    
    // Stats
    var timesCompleted: Int
    var isFavorite: Bool
    
    init(
        name: String,
        description: String,
        category: ExerciseCategory,
        difficulty: Difficulty,
        duration: TimeInterval = 30,
        instructions: [String] = [],
        benefits: [String] = [],
        isPremium: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.exerciseDescription = description
        self.category = category
        self.difficulty = difficulty
        self.duration = duration
        self.restDuration = 15
        self.instructions = instructions
        self.tips = []
        self.warnings = []
        self.benefits = benefits
        self.targetMuscles = []
        self.isPremium = isPremium
        self.equipmentNeeded = []
        self.modifications = []
        self.voiceInstructions = []
        self.timesCompleted = 0
        self.isFavorite = false
    }
}

// MARK: - Exercise Category
enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case balance = "Balance"
    case strength = "Strength"
    case flexibility = "Flexibility"
    case fallPrevention = "Fall Prevention"
    case posture = "Posture"
    case breathing = "Breathing"
    case warmup = "Warm Up"
    case cooldown = "Cool Down"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .balance: return "figure.stand"
        case .strength: return "figure.strengthtraining.traditional"
        case .flexibility: return "figure.flexibility"
        case .fallPrevention: return "figure.fall"
        case .posture: return "figure.stand.line.dotted.figure.stand"
        case .breathing: return "wind"
        case .warmup: return "flame"
        case .cooldown: return "snowflake"
        }
    }
    
    var color: String {
        switch self {
        case .balance: return "2A9D8F"
        case .strength: return "E76F51"
        case .flexibility: return "F4A261"
        case .fallPrevention: return "E9C46A"
        case .posture: return "264653"
        case .breathing: return "118AB2"
        case .warmup: return "EF476F"
        case .cooldown: return "06D6A0"
        }
    }
    
    var description: String {
        switch self {
        case .balance:
            return "Improve stability and coordination"
        case .strength:
            return "Build muscle and bone strength"
        case .flexibility:
            return "Increase range of motion"
        case .fallPrevention:
            return "Reduce risk of falls"
        case .posture:
            return "Improve alignment and reduce pain"
        case .breathing:
            return "Relaxation and stress relief"
        case .warmup:
            return "Prepare your body for exercise"
        case .cooldown:
            return "Gentle exercises to end your workout"
        }
    }
}

// MARK: - Difficulty Level
enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case moderate = "Moderate"
    case challenging = "Challenging"
    
    var icon: String {
        switch self {
        case .easy: return "1.circle.fill"
        case .moderate: return "2.circle.fill"
        case .challenging: return "3.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "06D6A0"
        case .moderate: return "FFB703"
        case .challenging: return "E76F51"
        }
    }
    
    var description: String {
        switch self {
        case .easy:
            return "Great for beginners, gentle movements"
        case .moderate:
            return "Moderate effort, builds on basics"
        case .challenging:
            return "More advanced, requires good mobility"
        }
    }
}

// MARK: - Equipment
enum Equipment: String, Codable, CaseIterable {
    case none = "No Equipment"
    case chair = "Sturdy Chair"
    case wall = "Wall"
    case resistanceBand = "Resistance Band"
    case lightWeights = "Light Weights"
    case mat = "Exercise Mat"
    case towel = "Towel"
    case counter = "Kitchen Counter"
    
    var icon: String {
        switch self {
        case .none: return "hand.raised"
        case .chair: return "chair"
        case .wall: return "square.fill"
        case .resistanceBand: return "link"
        case .lightWeights: return "scalemass"
        case .mat: return "rectangle.fill"
        case .towel: return "leaf"
        case .counter: return "rectangle.topthird.inset.filled"
        }
    }
}

// MARK: - Exercise Modification
struct ExerciseModification: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var forCondition: String // e.g., "knee pain", "limited mobility"
}

// MARK: - Voice Instruction
struct VoiceInstruction: Codable, Identifiable {
    var id: UUID = UUID()
    var timeOffset: TimeInterval // when to speak (seconds from start)
    var text: String
    var type: InstructionType
    
    enum InstructionType: String, Codable {
        case intro = "Introduction"
        case instruction = "Instruction"
        case encouragement = "Encouragement"
        case countdown = "Countdown"
        case transition = "Transition"
        case completion = "Completion"
    }
}

// MARK: - Sample Exercises
extension Exercise {
    static var sampleExercises: [Exercise] {
        [
            // Balance Exercises
            Exercise(
                name: "Single Leg Stand",
                description: "Stand on one leg while holding onto a chair for support. Great for improving balance.",
                category: .balance,
                difficulty: .easy,
                duration: 30,
                instructions: [
                    "Stand behind a sturdy chair, holding the back with both hands",
                    "Slowly lift your right foot off the ground",
                    "Hold for 10-15 seconds",
                    "Lower your foot and repeat with the left leg",
                    "Complete 3 repetitions on each side"
                ],
                benefits: ["Improves balance", "Strengthens ankle muscles", "Builds confidence"],
                isPremium: false
            ),
            
            Exercise(
                name: "Heel-Toe Walk",
                description: "Walk in a straight line placing heel directly in front of toes. Excellent for balance training.",
                category: .fallPrevention,
                difficulty: .moderate,
                duration: 60,
                instructions: [
                    "Stand near a wall for support if needed",
                    "Place your right heel directly in front of your left toes",
                    "Then place your left heel in front of your right toes",
                    "Walk 15-20 steps forward",
                    "Turn around carefully and walk back"
                ],
                benefits: ["Improves walking balance", "Enhances coordination", "Builds core stability"],
                isPremium: false
            ),
            
            // Strength Exercises
            Exercise(
                name: "Chair Stand",
                description: "Practice sitting down and standing up from a chair without using hands.",
                category: .strength,
                difficulty: .easy,
                duration: 45,
                instructions: [
                    "Sit in a sturdy chair with feet flat on the floor",
                    "Cross your arms over your chest",
                    "Lean slightly forward and stand up slowly",
                    "Pause briefly, then slowly sit back down",
                    "Complete 8-10 repetitions"
                ],
                benefits: ["Strengthens legs", "Improves ability to get up", "Builds independence"],
                isPremium: false
            ),
            
            Exercise(
                name: "Wall Push-Ups",
                description: "A gentle push-up against the wall to strengthen arms and chest.",
                category: .strength,
                difficulty: .easy,
                duration: 45,
                instructions: [
                    "Stand arm's length from a wall",
                    "Place palms flat on the wall at shoulder height",
                    "Slowly bend elbows and lean toward the wall",
                    "Push back to starting position",
                    "Complete 10-15 repetitions"
                ],
                benefits: ["Strengthens arms", "Improves upper body strength", "Easy on joints"],
                isPremium: false
            ),
            
            // Flexibility Exercises
            Exercise(
                name: "Shoulder Rolls",
                description: "Gentle circular movements to release shoulder tension.",
                category: .flexibility,
                difficulty: .easy,
                duration: 30,
                instructions: [
                    "Sit or stand comfortably with arms at your sides",
                    "Slowly roll shoulders forward in circles",
                    "Complete 5 circles forward",
                    "Reverse direction and complete 5 circles backward",
                    "Repeat 2-3 times"
                ],
                benefits: ["Releases shoulder tension", "Improves mobility", "Reduces stiffness"],
                isPremium: false
            ),
            
            Exercise(
                name: "Neck Stretches",
                description: "Gentle side-to-side stretches for neck flexibility.",
                category: .flexibility,
                difficulty: .easy,
                duration: 45,
                instructions: [
                    "Sit or stand with good posture",
                    "Slowly tilt your head toward your right shoulder",
                    "Hold for 10-15 seconds",
                    "Return to center and repeat on left side",
                    "Complete 3 stretches on each side"
                ],
                benefits: ["Relieves neck tension", "Improves flexibility", "Reduces headaches"],
                isPremium: false
            ),
            
            // Posture Exercises
            Exercise(
                name: "Chin Tucks",
                description: "Strengthen neck muscles and improve forward head posture.",
                category: .posture,
                difficulty: .easy,
                duration: 30,
                instructions: [
                    "Sit or stand with good posture",
                    "Look straight ahead",
                    "Gently draw your chin back as if making a double chin",
                    "Hold for 5 seconds",
                    "Relax and repeat 10 times"
                ],
                benefits: ["Improves posture", "Reduces neck strain", "Strengthens neck muscles"],
                isPremium: false
            ),
            
            // Breathing Exercises
            Exercise(
                name: "Deep Breathing",
                description: "Calming deep breaths to reduce stress and improve relaxation.",
                category: .breathing,
                difficulty: .easy,
                duration: 60,
                instructions: [
                    "Sit comfortably with hands on your belly",
                    "Breathe in slowly through your nose for 4 counts",
                    "Feel your belly rise as you inhale",
                    "Slowly exhale through your mouth for 6 counts",
                    "Repeat 5-10 times"
                ],
                benefits: ["Reduces stress", "Improves oxygen flow", "Promotes relaxation"],
                isPremium: false
            )
        ]
    }
}
