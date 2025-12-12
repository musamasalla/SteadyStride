//
//  SteadyStrideApp.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData

@main
struct SteadyStrideApp: App {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Exercise.self,
            Routine.self,
            WorkoutSession.self,
            ProgressEntry.self,
            Achievement.self,
            FamilyMember.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView(isOnboardingComplete: $isOnboardingComplete)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Root View
struct RootView: View {
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        Group {
            if isOnboardingComplete {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isOnboardingComplete)
    }
}

#Preview {
    RootView(isOnboardingComplete: .constant(false))
        .modelContainer(for: [User.self, Exercise.self], inMemory: true)
}
