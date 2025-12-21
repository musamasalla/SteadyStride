//
//  SteadyStrideApp.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.steadystride.app", category: "App")

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
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.steadystride.app")
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Log the error for debugging
            logger.error("Failed to create ModelContainer: \(error.localizedDescription)")
            
            // Fall back to in-memory storage so app doesn't crash
            logger.warning("Falling back to in-memory storage")
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                // This should never happen with in-memory storage
                fatalError("Could not create fallback ModelContainer: \(error)")
            }
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
