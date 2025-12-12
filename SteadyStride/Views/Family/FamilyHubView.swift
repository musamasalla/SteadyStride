//
//  FamilyHubView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData

struct FamilyHubView: View {
    @State private var showingInvite = false
    @State private var familyMembers: [FamilyMember] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    if familyMembers.isEmpty {
                        emptyStateView
                    } else {
                        familyMembersList
                        activityFeed
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xxl)
            }
            .background(Color.steadyBackground)
            .navigationTitle("Family")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingInvite = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.steadyPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingInvite) {
                InviteFamilyView()
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()
            
            Image(systemName: "person.2.fill")
                .font(.system(size: 80))
                .foregroundColor(.steadyTextTertiary)
            
            Text("Share Your Progress")
                .font(Typography.headlineLarge)
                .foregroundColor(.steadyTextPrimary)
            
            Text("Invite family members to follow your journey. They can send encouragement and check in on your progress.")
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
            
            Button {
                showingInvite = true
            } label: {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Invite Family Member")
                }
            }
            .buttonStyle(.primary)
            .padding(.horizontal, Theme.Spacing.lg)
            
            Spacer()
        }
        .padding(.vertical, Theme.Spacing.xxl)
    }
    
    // MARK: - Family Members List
    private var familyMembersList: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Connected Family")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            ForEach(familyMembers, id: \.id) { member in
                FamilyMemberRow(member: member)
            }
        }
    }
    
    // MARK: - Activity Feed
    private var activityFeed: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Recent Activity")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            // Sample activity items
            VStack(spacing: Theme.Spacing.sm) {
                ActivityFeedItem(
                    name: "Sarah",
                    action: "sent you encouragement",
                    emoji: "👏",
                    timeAgo: "2 hours ago"
                )
                
                ActivityFeedItem(
                    name: "Michael",
                    action: "checked in on your progress",
                    emoji: "👀",
                    timeAgo: "Yesterday"
                )
            }
        }
    }
}

// MARK: - Family Member Row
struct FamilyMemberRow: View {
    let member: FamilyMember
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Avatar
            Circle()
                .fill(Color(hex: member.avatarColor))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(member.name.prefix(1)))
                        .font(Typography.headlineMedium)
                        .foregroundColor(.white)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(Typography.labelLarge)
                    .foregroundColor(.steadyTextPrimary)
                
                Text(member.relationship.rawValue)
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextSecondary)
            }
            
            Spacer()
            
            // Status indicator
            Circle()
                .fill(Color(hex: member.inviteStatus.color))
                .frame(width: 10, height: 10)
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .fill(Color.steadyCardBackground)
        )
    }
}

// MARK: - Activity Feed Item
struct ActivityFeedItem: View {
    let name: String
    let action: String
    let emoji: String
    let timeAgo: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Text(emoji)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Theme.Spacing.xs) {
                    Text(name)
                        .font(Typography.labelMedium)
                        .foregroundColor(.steadyTextPrimary)
                    
                    Text(action)
                        .font(Typography.bodySmall)
                        .foregroundColor(.steadyTextSecondary)
                }
                
                Text(timeAgo)
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextTertiary)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.md)
                .fill(Color.steadyBackgroundSecondary)
        )
    }
}

// MARK: - Invite Family View
struct InviteFamilyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var selectedRelationship: FamilyRelationship = .child
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Family Member Info") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Relationship") {
                    Picker("Relationship", selection: $selectedRelationship) {
                        ForEach(FamilyRelationship.allCases, id: \.self) { relation in
                            Label(relation.rawValue, systemImage: relation.icon)
                                .tag(relation)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Permissions") {
                    Toggle("View my progress", isOn: .constant(true))
                    Toggle("Send me encouragement", isOn: .constant(true))
                    Toggle("Receive alerts", isOn: .constant(true))
                }
                
                Section {
                    Button {
                        // Send invite
                        dismiss()
                    } label: {
                        Text("Send Invitation")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.primary)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Invite Family")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    FamilyHubView()
}
