//
//  ProfileView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @State private var showingSubscription = false
    @State private var voiceEnabled = true
    @State private var voiceSpeed: VoiceSpeed = .normal
    @State private var hapticEnabled = true
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Header
                profileHeader
                
                // Subscription
                subscriptionSection
                
                // Voice Settings
                voiceSection
                
                // Accessibility
                accessibilitySection
                
                // Health
                healthSection
                
                // Support
                supportSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .sheet(isPresented: $showingSubscription) {
                PaywallView()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        Section {
            HStack(spacing: Theme.Spacing.md) {
                Circle()
                    .fill(Color.steadyPrimaryLight)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.steadyPrimary)
                    )
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text("Welcome!")
                        .font(Typography.headlineMedium)
                        .foregroundColor(.steadyTextPrimary)
                    
                    Text("Member since Dec 2025")
                        .font(Typography.caption)
                        .foregroundColor(.steadyTextSecondary)
                }
                
                Spacer()
                
                Button {
                    // Edit profile
                } label: {
                    Text("Edit")
                        .font(Typography.labelMedium)
                        .foregroundColor(.steadyPrimary)
                }
            }
        }
    }
    
    // MARK: - Subscription Section
    private var subscriptionSection: some View {
        Section("Subscription") {
            Button {
                showingSubscription = true
            } label: {
                HStack {
                    Label("Free Plan", systemImage: "star")
                        .foregroundColor(.steadyTextPrimary)
                    
                    Spacer()
                    
                    Text("Upgrade")
                        .font(Typography.labelMedium)
                        .foregroundColor(.steadyPrimary)
                }
            }
        }
    }
    
    // MARK: - Voice Section
    private var voiceSection: some View {
        Section("Voice Guidance") {
            Toggle(isOn: $voiceEnabled) {
                Label("Voice Coaching", systemImage: "speaker.wave.3.fill")
            }
            
            if voiceEnabled {
                Picker(selection: $voiceSpeed) {
                    ForEach(VoiceSpeed.allCases, id: \.self) { speed in
                        Text(speed.rawValue).tag(speed)
                    }
                } label: {
                    Label("Speaking Speed", systemImage: "gauge.medium")
                }
            }
        }
    }
    
    // MARK: - Accessibility Section
    private var accessibilitySection: some View {
        Section("Accessibility") {
            Toggle(isOn: $hapticEnabled) {
                Label("Haptic Feedback", systemImage: "hand.tap.fill")
            }
            
            NavigationLink {
                Text("Text Size Settings")
            } label: {
                Label("Text Size", systemImage: "textformat.size")
            }
        }
    }
    
    // MARK: - Health Section
    private var healthSection: some View {
        Section("Health & Data") {
            NavigationLink {
                Text("HealthKit Settings")
            } label: {
                Label("HealthKit", systemImage: "heart.text.square.fill")
            }
            
            NavigationLink {
                Text("Apple Watch Settings")
            } label: {
                Label("Apple Watch", systemImage: "applewatch")
            }
            
            NavigationLink {
                Text("Export Data")
            } label: {
                Label("Export My Data", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        Section("Support") {
            NavigationLink {
                Text("Help Center")
            } label: {
                Label("Help Center", systemImage: "questionmark.circle")
            }
            
            NavigationLink {
                Text("Contact Support")
            } label: {
                Label("Contact Us", systemImage: "envelope")
            }
            
            NavigationLink {
                Text("Privacy Policy")
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            
            NavigationLink {
                Text("Terms of Service")
            } label: {
                Label("Terms of Service", systemImage: "doc.text")
            }
        }
    }
}

// MARK: - Paywall View
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Header
                    VStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.celebrationGradient)
                        
                        Text("Unlock Your Full Potential")
                            .font(Typography.displaySmall)
                            .foregroundColor(.steadyTextPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Get unlimited access to all exercises, personalized coaching, and family features")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.steadyTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Theme.Spacing.xl)
                    
                    // Features
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        FeatureRow(icon: "infinity", text: "Unlimited exercises & routines")
                        FeatureRow(icon: "speaker.wave.3.fill", text: "Full voice coaching")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Complete progress history")
                        FeatureRow(icon: "person.2.fill", text: "Family sharing")
                        FeatureRow(icon: "doc.text.fill", text: "Doctor-friendly reports")
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    
                    // Pricing Options
                    VStack(spacing: Theme.Spacing.md) {
                        PricingCard(
                            title: "Full Access",
                            price: "$9.99",
                            period: "one-time",
                            description: "Unlock all exercises forever",
                            isPopular: false
                        )
                        
                        PricingCard(
                            title: "Premium Coach",
                            price: "$2.99",
                            period: "per month",
                            description: "Everything + personalized coaching",
                            isPopular: true
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    
                    // Restore
                    Button("Restore Purchases") {
                        // Restore
                    }
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyTextSecondary)
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color.steadyBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.steadyTextTertiary)
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.steadyPrimary)
                .frame(width: 32)
            
            Text(text)
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextPrimary)
        }
    }
}

struct PricingCard: View {
    let title: String
    let price: String
    let period: String
    let description: String
    let isPopular: Bool
    
    var body: some View {
        Button {
            // Purchase
        } label: {
            VStack(spacing: Theme.Spacing.sm) {
                if isPopular {
                    Text("MOST POPULAR")
                        .font(Typography.overline)
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xxs)
                        .background(Capsule().fill(Color.steadySecondary))
                }
                
                Text(title)
                    .font(Typography.headlineSmall)
                    .foregroundColor(.steadyTextPrimary)
                
                HStack(alignment: .lastTextBaseline, spacing: Theme.Spacing.xxs) {
                    Text(price)
                        .font(Typography.displaySmall)
                        .foregroundColor(.steadyPrimary)
                    
                    Text(period)
                        .font(Typography.bodySmall)
                        .foregroundColor(.steadyTextSecondary)
                }
                
                Text(description)
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .fill(Color.steadyCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.lg)
                            .stroke(isPopular ? Color.steadyPrimary : Color.steadyBorder, lineWidth: isPopular ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
}
