//
//  AppState.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftUI
import SwiftData

/// Global app state management
@MainActor
@Observable
class AppState {
    
    // MARK: - Singleton
    static let shared = AppState()
    
    // MARK: - State Properties
    var isOnboardingComplete: Bool {
        get { UserDefaults.standard.bool(forKey: "isOnboardingComplete") }
        set { UserDefaults.standard.set(newValue, forKey: "isOnboardingComplete") }
    }
    
    var currentUser: User?
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Navigation
    var selectedTab: AppTab = .home
    var showingPaywall: Bool = false
    var showingSettings: Bool = false
    
    // MARK: - Services
    let healthKitService = HealthKitService.shared
    let voiceCoachService = VoiceCoachService.shared
    let watchService = WatchConnectivityService.shared
    let subscriptionService = SubscriptionService.shared
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Methods
    func completeOnboarding() {
        isOnboardingComplete = true
    }
    
    func resetOnboarding() {
        isOnboardingComplete = false
    }
}

// MARK: - App Tab
enum AppTab: String, CaseIterable {
    case home = "Home"
    case exercises = "Exercises"
    case progress = "Progress"
    case family = "Family"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .exercises: return "figure.walk"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .family: return "person.2.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}
