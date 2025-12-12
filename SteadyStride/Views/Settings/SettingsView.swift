//
//  SettingsView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("voiceGuidanceEnabled") private var voiceGuidanceEnabled = true
    @AppStorage("voiceSpeed") private var voiceSpeed = 0.5
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("highContrastMode") private var highContrastMode = false
    @AppStorage("preferredWorkoutTime") private var preferredWorkoutTime = "morning"
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Notifications
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Workout Reminders", systemImage: "bell.fill")
                    }
                    .tint(.steadyPrimary)
                    
                    if notificationsEnabled {
                        Picker(selection: $preferredWorkoutTime) {
                            Text("Morning (8 AM)").tag("morning")
                            Text("Afternoon (2 PM)").tag("afternoon")
                            Text("Evening (6 PM)").tag("evening")
                        } label: {
                            Label("Reminder Time", systemImage: "clock.fill")
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get reminded to complete your daily workout")
                }
                
                // MARK: - Voice Guidance
                Section {
                    Toggle(isOn: $voiceGuidanceEnabled) {
                        Label("Voice Coaching", systemImage: "speaker.wave.2.fill")
                    }
                    .tint(.steadyPrimary)
                    
                    if voiceGuidanceEnabled {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            HStack {
                                Label("Speech Speed", systemImage: "gauge.medium")
                                Spacer()
                                Text(speedLabel)
                                    .foregroundColor(.steadyTextSecondary)
                            }
                            
                            Slider(value: $voiceSpeed, in: 0.3...0.7, step: 0.1)
                                .tint(.steadyPrimary)
                        }
                    }
                } header: {
                    Text("Voice Guidance")
                } footer: {
                    Text("Receive spoken instructions during exercises")
                }
                
                // MARK: - Accessibility
                Section {
                    Toggle(isOn: $hapticFeedbackEnabled) {
                        Label("Haptic Feedback", systemImage: "hand.tap.fill")
                    }
                    .tint(.steadyPrimary)
                    
                    Toggle(isOn: $highContrastMode) {
                        Label("High Contrast", systemImage: "circle.lefthalf.filled")
                    }
                    .tint(.steadyPrimary)
                    
                    NavigationLink {
                        // Text size settings - would link to system settings
                        Text("Text Size Settings")
                    } label: {
                        Label("Text Size", systemImage: "textformat.size")
                    }
                } header: {
                    Text("Accessibility")
                } footer: {
                    Text("Customize the app for your comfort")
                }
                
                // MARK: - Health & Data
                Section {
                    NavigationLink {
                        HealthKitSettingsView()
                    } label: {
                        Label("HealthKit", systemImage: "heart.fill")
                    }
                    
                    NavigationLink {
                        // Watch settings
                        Text("Watch Connection Settings")
                    } label: {
                        Label("Apple Watch", systemImage: "applewatch")
                    }
                    
                    Button {
                        // Export data action
                    } label: {
                        Label("Export My Data", systemImage: "square.and.arrow.up")
                    }
                } header: {
                    Text("Health & Data")
                }
                
                // MARK: - Support
                Section {
                    Link(destination: URL(string: "https://steadystride.app/help")!) {
                        Label("Help Center", systemImage: "questionmark.circle.fill")
                    }
                    
                    Link(destination: URL(string: "mailto:support@steadystride.app")!) {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                    
                    Link(destination: URL(string: "https://steadystride.app/privacy")!) {
                        Label("Privacy Policy", systemImage: "lock.shield.fill")
                    }
                    
                    Link(destination: URL(string: "https://steadystride.app/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                } header: {
                    Text("Support")
                }
                
                // MARK: - About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.steadyTextSecondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var speedLabel: String {
        switch voiceSpeed {
        case ..<0.4: return "Slow"
        case 0.4..<0.6: return "Normal"
        default: return "Fast"
        }
    }
}

// MARK: - HealthKit Settings View
struct HealthKitSettingsView: View {
    @State private var healthKitAuthorized = false
    @State private var syncSteps = true
    @State private var syncHeartRate = true
    @State private var syncWorkouts = true
    @State private var isLoading = false
    
    var body: some View {
        List {
            Section {
                if healthKitAuthorized {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.steadySuccess)
                        Text("HealthKit Connected")
                            .font(Typography.bodyMedium)
                    }
                } else {
                    Button {
                        // Request authorization
                        Task {
                            await requestHealthKitAuth()
                        }
                    } label: {
                        HStack {
                            Label("Connect HealthKit", systemImage: "heart.fill")
                            Spacer()
                            if isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isLoading)
                }
            } header: {
                Text("Status")
            }
            
            if healthKitAuthorized {
                Section {
                    Toggle(isOn: $syncSteps) {
                        Label("Steps", systemImage: "figure.walk")
                    }
                    .tint(.steadyPrimary)
                    
                    Toggle(isOn: $syncHeartRate) {
                        Label("Heart Rate", systemImage: "heart.fill")
                    }
                    .tint(.steadyPrimary)
                    
                    Toggle(isOn: $syncWorkouts) {
                        Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                    }
                    .tint(.steadyPrimary)
                } header: {
                    Text("Sync Settings")
                } footer: {
                    Text("Choose what data to sync with Apple Health")
                }
            }
        }
        .navigationTitle("HealthKit")
    }
    
    private func requestHealthKitAuth() async {
        isLoading = true
        try? await HealthKitService.shared.requestAuthorization()
        healthKitAuthorized = true
        isLoading = false
    }
}

#Preview {
    SettingsView()
}
