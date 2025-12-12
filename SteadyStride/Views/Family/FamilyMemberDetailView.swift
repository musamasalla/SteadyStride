//
//  FamilyMemberDetailView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

struct FamilyMemberDetailView: View {
    let member: FamilyMember
    @State private var showingEncouragementSheet = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                // Profile Header
                profileHeader
                
                // Quick Actions
                quickActions
                
                // Permissions
                permissionsSection
                
                // Notification Settings
                notificationSettings
                
                // Remove Member
                removeMemberButton
            }
            .padding(Theme.Spacing.lg)
        }
        .background(Color.steadyBackground)
        .navigationTitle(member.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEncouragementSheet) {
            SendEncouragementSheet(member: member)
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Avatar
            AvatarView(name: member.name, color: member.avatarColor, size: 80)
            
            // Name
            Text(member.name)
                .font(Typography.headlineLarge)
                .foregroundColor(.steadyTextPrimary)
            
            // Relationship
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: member.relationship.icon)
                Text(member.relationship.rawValue)
            }
            .font(Typography.labelMedium)
            .foregroundColor(.steadyTextSecondary)
            
            // Status
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: member.inviteStatus.icon)
                    .foregroundColor(Color(hex: member.inviteStatus.color))
                Text(member.inviteStatus.rawValue)
                    .foregroundColor(Color(hex: member.inviteStatus.color))
            }
            .font(Typography.caption)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.xs)
            .background(Color(hex: member.inviteStatus.color).opacity(0.15))
            .cornerRadius(Theme.Radius.full)
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.steadyCardBackground)
        .cornerRadius(Theme.Radius.lg)
    }
    
    // MARK: - Quick Actions
    private var quickActions: some View {
        HStack(spacing: Theme.Spacing.md) {
            ActionButton(
                title: "Encourage",
                icon: "hands.clap.fill",
                color: .steadySecondary
            ) {
                showingEncouragementSheet = true
            }
            
            ActionButton(
                title: "Check In",
                icon: "hand.wave.fill",
                color: .steadyPrimary
            ) {
                requestCheckIn()
            }
        }
    }
    
    // MARK: - Permissions Section
    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Role & Permissions")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            VStack(spacing: Theme.Spacing.sm) {
                PermissionRow(
                    title: "Role",
                    value: member.role.rawValue,
                    icon: "person.badge.shield.checkmark"
                )
                
                PermissionRow(
                    title: "View Progress",
                    isEnabled: member.canViewProgress,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                PermissionRow(
                    title: "Receive Alerts",
                    isEnabled: member.canReceiveAlerts,
                    icon: "bell.badge.fill"
                )
                
                PermissionRow(
                    title: "Send Encouragement",
                    isEnabled: member.canSendEncouragement,
                    icon: "heart.fill"
                )
            }
            .padding(Theme.Spacing.md)
            .background(Color.steadyCardBackground)
            .cornerRadius(Theme.Radius.md)
        }
    }
    
    // MARK: - Notification Settings
    private var notificationSettings: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Notifications")
                .font(Typography.headlineSmall)
                .foregroundColor(.steadyTextPrimary)
            
            VStack(spacing: Theme.Spacing.sm) {
                NotificationToggle(
                    title: "Workout Complete",
                    isEnabled: member.notifyOnWorkoutComplete,
                    icon: "checkmark.circle.fill"
                )
                
                NotificationToggle(
                    title: "Streak Milestone",
                    isEnabled: member.notifyOnStreakMilestone,
                    icon: "flame.fill"
                )
                
                NotificationToggle(
                    title: "Missed Workout",
                    isEnabled: member.notifyOnMissedWorkout,
                    icon: "exclamationmark.circle.fill"
                )
                
                NotificationToggle(
                    title: "Emergency",
                    isEnabled: member.notifyOnEmergency,
                    icon: "exclamationmark.triangle.fill"
                )
            }
            .padding(Theme.Spacing.md)
            .background(Color.steadyCardBackground)
            .cornerRadius(Theme.Radius.md)
        }
    }
    
    // MARK: - Remove Button
    private var removeMemberButton: some View {
        Button(role: .destructive) {
            removeMember()
        } label: {
            Label("Remove Family Member", systemImage: "person.badge.minus")
        }
        .buttonStyle(.bordered)
        .tint(.steadyError)
    }
    
    // MARK: - Actions
    private func requestCheckIn() {
        FamilySharingService.shared.requestCheckIn(from: member)
    }
    
    private func removeMember() {
        FamilySharingService.shared.removeFamilyMember(member)
        dismiss()
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(Typography.labelMedium)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.lg)
            .background(color.opacity(0.15))
            .cornerRadius(Theme.Radius.md)
        }
    }
}

// MARK: - Permission Row
struct PermissionRow: View {
    let title: String
    var value: String? = nil
    var isEnabled: Bool? = nil
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.steadyPrimary)
                .frame(width: 24)
            
            Text(title)
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextPrimary)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyTextSecondary)
            } else if let isEnabled = isEnabled {
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isEnabled ? .steadySuccess : .steadyTextTertiary)
            }
        }
    }
}

// MARK: - Notification Toggle
struct NotificationToggle: View {
    let title: String
    let isEnabled: Bool
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.steadyPrimary)
                .frame(width: 24)
            
            Text(title)
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextPrimary)
            
            Spacer()
            
            Toggle("", isOn: .constant(isEnabled))
                .tint(.steadyPrimary)
        }
    }
}

// MARK: - Send Encouragement Sheet
struct SendEncouragementSheet: View {
    let member: FamilyMember
    @State private var selectedMessage: (emoji: String, message: String)?
    @State private var customMessage: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                Text("Send encouragement to \(member.name)")
                    .font(Typography.headlineSmall)
                    .foregroundColor(.steadyTextPrimary)
                
                // Quick Messages
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                    ForEach(EncouragementMessage.presetMessages, id: \.0) { preset in
                        QuickMessageButton(
                            emoji: preset.0,
                            message: preset.1,
                            isSelected: selectedMessage?.message == preset.1
                        ) {
                            selectedMessage = preset
                        }
                    }
                }
                
                // Custom Message
                TextField("Or write a custom message...", text: $customMessage)
                    .textFieldStyle(.roundedBorder)
                    .font(Typography.bodyMedium)
                
                Spacer()
                
                // Send Button
                Button {
                    sendEncouragement()
                } label: {
                    Text("Send Encouragement")
                }
                .buttonStyle(.primary)
                .disabled(selectedMessage == nil && customMessage.isEmpty)
            }
            .padding(Theme.Spacing.lg)
            .navigationTitle("Encouragement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sendEncouragement() {
        let message = customMessage.isEmpty ? (selectedMessage?.message ?? "") : customMessage
        let emoji = selectedMessage?.emoji ?? "👏"
        FamilySharingService.shared.sendEncouragement(to: member, message: message, emoji: emoji)
        dismiss()
    }
}

// MARK: - Quick Message Button
struct QuickMessageButton: View {
    let emoji: String
    let message: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xs) {
                Text(emoji)
                    .font(.system(size: 28))
                Text(message)
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.steadyPrimary.opacity(0.2) : Color.steadyCardBackground)
            .cornerRadius(Theme.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .stroke(isSelected ? Color.steadyPrimary : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    NavigationStack {
        FamilyMemberDetailView(member: {
            let member = FamilyMember(name: "Sarah", email: "sarah@example.com", relationship: .child)
            member.inviteStatus = .accepted
            return member
        }())
    }
}
