//
//  WatchHomeView.swift
//  SteadyStride Watch App
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

/// Home view for Apple Watch app
struct WatchHomeView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @State private var todayComplete: Bool = false
    @State private var currentStreak: Int = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Streak
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(connectivity.currentStreak) day streak")
                            .font(.caption)
                    }
                    
                    // Today's Status
                    VStack(spacing: 4) {
                        Image(systemName: connectivity.todayComplete ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 40))
                            .foregroundColor(connectivity.todayComplete ? .green : .gray)
                        
                        Text(connectivity.todayComplete ? "Complete!" : "Today's Workout")
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                    
                    // Quick Start Buttons
                    if !connectivity.todayComplete {
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
                    if connectivity.isPhoneReachable {
                        HStack(spacing: 4) {
                            Image(systemName: "iphone")
                            Text("Synced")
                        }
                        .font(.caption2)
                        .foregroundColor(.green)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "iphone.slash")
                            Text("Offline")
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("SteadyStride")
        }
    }
}

#Preview {
    WatchHomeView()
        .environment(WatchConnectivityManager.shared)
}
