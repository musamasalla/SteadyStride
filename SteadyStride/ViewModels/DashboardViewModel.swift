//
//  DashboardViewModel.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class DashboardViewModel {
    
    // MARK: - State
    var todayWorkout: Routine?
    var recentSessions: [WorkoutSession] = []
    var currentStreak: Int = 0
    var todayProgress: Double = 0
    var weeklyProgress: [Date: Bool] = [:]
    var isLoading: Bool = false
    
    // MARK: - Health Data
    var todaySteps: Int = 0
    var todayActiveMinutes: Int = 0
    var currentHeartRate: Double?
    
    // MARK: - Greeting
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Hello"
        }
    }
    
    var motivationalMessage: String {
        let messages = [
            "Every step counts towards a healthier you!",
            "You're stronger than you think.",
            "Small progress is still progress.",
            "Your future self will thank you.",
            "Consistency is key to success.",
            "Today is a great day to feel better!"
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Load Data
    func loadDashboardData(modelContext: ModelContext) async {
        isLoading = true
        
        // Load health data
        await HealthKitService.shared.fetchTodayData()
        todaySteps = HealthKitService.shared.todaySteps
        todayActiveMinutes = HealthKitService.shared.todayActiveMinutes
        currentHeartRate = HealthKitService.shared.latestHeartRate
        
        // Load recommended workout from database
        let descriptor = FetchDescriptor<Routine>(
            predicate: #Predicate { $0.isRecommended },
            sortBy: [SortDescriptor(\.name)]
        )
        let routines = (try? modelContext.fetch(descriptor)) ?? []
        
        // Use database routine or fall back to sample for initial experience
        if let dbRoutine = routines.first {
            todayWorkout = dbRoutine
        } else {
            todayWorkout = Routine.sampleRoutines.first { $0.isRecommended }
        }
        
        isLoading = false
    }
    
    func loadRecentSessions(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<WorkoutSession>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        let allSessions = (try? modelContext.fetch(descriptor)) ?? []
        recentSessions = allSessions.filter { $0.status == .completed }
    }
    
}
