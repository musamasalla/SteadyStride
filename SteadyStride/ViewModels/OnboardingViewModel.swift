//
//  OnboardingViewModel.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class OnboardingViewModel {
    
    // MARK: - State
    var currentStep: OnboardingStep = .welcome
    var name: String = ""
    var age: Int = 65
    var selectedGoals: Set<HealthGoal> = []
    var selectedMobilityLevel: MobilityLevel = .beginner
    var preferredWorkoutTime: TimeOfDay = .morning
    var hasAcceptedHealthKit: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Computed
    var canProceed: Bool {
        switch currentStep {
        case .welcome: return true
        case .name: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case .age: return age >= 18
        case .goals: return !selectedGoals.isEmpty
        case .mobility: return true
        case .schedule: return true
        case .healthKit: return true
        case .complete: return true
        }
    }
    
    var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    // MARK: - Navigation
    func nextStep() {
        guard let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.easeInOut) {
            currentStep = next
        }
    }
    
    func previousStep() {
        guard let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.easeInOut) {
            currentStep = prev
        }
    }
    
    // MARK: - HealthKit
    func requestHealthKitPermission() async {
        isLoading = true
        do {
            try await HealthKitService.shared.requestAuthorization()
            hasAcceptedHealthKit = true
        } catch {
            errorMessage = "HealthKit permission denied"
        }
        isLoading = false
    }
    
    // MARK: - Create User
    func createUser(modelContext: ModelContext) -> User {
        let user = User(
            name: name,
            age: age,
            mobilityLevel: selectedMobilityLevel,
            healthGoals: Array(selectedGoals)
        )
        user.hasCompletedOnboarding = true
        user.hasGrantedHealthKitPermission = hasAcceptedHealthKit
        
        modelContext.insert(user)
        return user
    }
}

// MARK: - Onboarding Steps
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case name = 1
    case age = 2
    case goals = 3
    case mobility = 4
    case schedule = 5
    case healthKit = 6
    case complete = 7
    
    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .name: return "Your Name"
        case .age: return "Your Age"
        case .goals: return "Your Goals"
        case .mobility: return "Current Mobility"
        case .schedule: return "Workout Time"
        case .healthKit: return "Health Data"
        case .complete: return "All Set!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome: return "Your journey to better mobility starts here"
        case .name: return "How should we address you?"
        case .age: return "This helps us personalize your exercises"
        case .goals: return "What would you like to achieve?"
        case .mobility: return "Where are you starting from?"
        case .schedule: return "When do you prefer to exercise?"
        case .healthKit: return "Track your progress with HealthKit"
        case .complete: return "You're ready to start!"
        }
    }
}
