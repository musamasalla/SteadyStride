//
//  WorkoutSession.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftData

// MARK: - Workout Session Model
@Model
final class WorkoutSession {
    var id: UUID
    var routineID: UUID?
    var routineName: String
    
    // Timing
    var startTime: Date
    var endTime: Date?
    var actualDuration: TimeInterval // in seconds
    var pausedDuration: TimeInterval // total time paused
    
    // Exercises
    var completedExerciseIDs: [UUID]
    var skippedExerciseIDs: [UUID]
    var totalExercises: Int
    
    // Health Data
    var heartRateSamples: [HeartRateSample]
    var averageHeartRate: Double?
    var maxHeartRate: Double?
    var minHeartRate: Double?
    var caloriesBurned: Double?
    var steps: Int?
    
    // Session Quality
    var difficultyRating: Int? // 1-5 user rating
    var enjoymentRating: Int? // 1-5 user rating
    var painLevel: Int? // 0-10 scale
    var notes: String?
    var mood: SessionMood?
    
    // Completion Status
    var status: SessionStatus
    var completionPercentage: Double
    
    // Synced
    var syncedToHealthKit: Bool
    var syncedToWatch: Bool
    var sharedWithFamily: Bool
    
    init(routineID: UUID? = nil, routineName: String) {
        self.id = UUID()
        self.routineID = routineID
        self.routineName = routineName
        self.startTime = Date()
        self.actualDuration = 0
        self.pausedDuration = 0
        self.completedExerciseIDs = []
        self.skippedExerciseIDs = []
        self.totalExercises = 0
        self.heartRateSamples = []
        self.status = .inProgress
        self.completionPercentage = 0
        self.syncedToHealthKit = false
        self.syncedToWatch = false
        self.sharedWithFamily = false
    }
    
    // MARK: - Computed Properties
    
    var isCompleted: Bool {
        status == .completed
    }
    
    var formattedDuration: String {
        let minutes = Int(actualDuration) / 60
        let seconds = Int(actualDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var exercisesCompletedCount: Int {
        completedExerciseIDs.count
    }
    
    var wasSuccessful: Bool {
        completionPercentage >= 0.7
    }
}

// MARK: - Heart Rate Sample
struct HeartRateSample: Codable, Identifiable {
    var id: UUID = UUID()
    var timestamp: Date
    var beatsPerMinute: Double
    var source: HeartRateSource
    
    enum HeartRateSource: String, Codable {
        case appleWatch = "Apple Watch"
        case manual = "Manual Entry"
    }
}

// MARK: - Session Status
enum SessionStatus: String, Codable {
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case paused = "Paused"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case skipped = "Skipped"
    
    var icon: String {
        switch self {
        case .scheduled: return "calendar"
        case .inProgress: return "play.fill"
        case .paused: return "pause.fill"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .skipped: return "forward.fill"
        }
    }
    
    var color: String {
        switch self {
        case .scheduled: return "118AB2"
        case .inProgress: return "2A9D8F"
        case .paused: return "FFB703"
        case .completed: return "06D6A0"
        case .cancelled: return "EF476F"
        case .skipped: return "8FA4B5"
        }
    }
}

// MARK: - Session Mood
enum SessionMood: String, Codable, CaseIterable {
    case great = "Great"
    case good = "Good"
    case okay = "Okay"
    case tired = "Tired"
    case struggling = "Struggling"
    
    var emoji: String {
        switch self {
        case .great: return "😊"
        case .good: return "🙂"
        case .okay: return "😐"
        case .tired: return "😴"
        case .struggling: return "😓"
        }
    }
    
    var description: String {
        switch self {
        case .great: return "Feeling energized and accomplished"
        case .good: return "Feeling positive about the workout"
        case .okay: return "Did what I could today"
        case .tired: return "Low energy, but I showed up"
        case .struggling: return "This was challenging today"
        }
    }
}

// MARK: - Workout Summary
struct WorkoutSummary: Identifiable {
    let id = UUID()
    let session: WorkoutSession
    
    var headline: String {
        if session.wasSuccessful {
            return "Great Workout! 🎉"
        } else if session.completionPercentage >= 0.5 {
            return "Nice Effort! 💪"
        } else {
            return "Every Step Counts! ⭐"
        }
    }
    
    var encouragement: String {
        if session.wasSuccessful {
            return "You completed \(Int(session.completionPercentage * 100))% of your workout. Keep up the amazing work!"
        } else {
            return "You showed up today, and that's what matters. Tomorrow is a new opportunity!"
        }
    }
}
