//
//  WatchHomeView.swift
//  SteadyStride Watch App
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

/// Home view for Apple Watch app
struct WatchHomeView: View {
    @State private var todayComplete: Bool = false
    @State private var currentStreak: Int = 7
    @State private var syncedWithPhone: Bool = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Streak
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(currentStreak) day streak")
                            .font(.caption)
                    }
                    
                    // Today's Status
                    VStack(spacing: 4) {
                        Image(systemName: todayComplete ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 40))
                            .foregroundColor(todayComplete ? .green : .gray)
                        
                        Text(todayComplete ? "Complete!" : "Today's Workout")
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                    
                    // Quick Start Buttons
                    if !todayComplete {
                        NavigationLink {
                            WatchWorkoutView()
                        } label: {
                            Label("Start Workout", systemImage: "play.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.teal)
                    }
                    
                    NavigationLink {
                        WatchHeartRateView()
                    } label: {
                        Label("Heart Rate", systemImage: "heart.fill")
                    }
                    .buttonStyle(.bordered)
                    
                    NavigationLink {
                        WatchQuickExercisesView()
                    } label: {
                        Label("Quick Exercise", systemImage: "figure.walk")
                    }
                    .buttonStyle(.bordered)
                    
                    // Sync status
                    if syncedWithPhone {
                        HStack(spacing: 4) {
                            Image(systemName: "iphone")
                            Text("Synced")
                        }
                        .font(.caption2)
                        .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("SteadyStride")
        }
    }
}

#Preview {
    WatchHomeView()
}
