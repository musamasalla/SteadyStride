//
//  FamilySharingService.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import CloudKit
import Combine

/// Service for managing family sharing features
@MainActor
class FamilySharingService: ObservableObject {
    
    static let shared = FamilySharingService()
    
    @Published var familyMembers: [FamilyMember] = []
    @Published var pendingInvites: [FamilyMember] = []
    @Published var activityFeed: [FamilyActivity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let container: CKContainer
    private let database: CKDatabase
    
    private init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
    }
    
    // MARK: - Family Member Management
    
    /// Invite a new family member
    func inviteFamilyMember(
        name: String,
        email: String,
        relationship: FamilyRelationship,
        role: FamilyRole = .viewer
    ) async throws -> FamilyMember {
        isLoading = true
        defer { isLoading = false }
        
        let member = FamilyMember(
            name: name,
            email: email,
            relationship: relationship,
            role: role
        )
        member.inviteStatus = .pending
        member.inviteSentDate = Date()
        
        // In production, this would save to CloudKit and send an email invite
        pendingInvites.append(member)
        
        return member
    }
    
    /// Accept a family invitation
    func acceptInvitation(for member: FamilyMember) {
        member.inviteStatus = .accepted
        member.inviteAcceptedDate = Date()
        
        if let index = pendingInvites.firstIndex(where: { $0.id == member.id }) {
            pendingInvites.remove(at: index)
        }
        familyMembers.append(member)
    }
    
    /// Remove a family member
    func removeFamilyMember(_ member: FamilyMember) {
        familyMembers.removeAll { $0.id == member.id }
        pendingInvites.removeAll { $0.id == member.id }
    }
    
    /// Update role for a family member
    func updateRole(for member: FamilyMember, role: FamilyRole) {
        member.role = role
    }
    
    // MARK: - Progress Sharing
    
    /// Share a workout completion with family
    func shareWorkoutCompletion(session: WorkoutSession) {
        let activity = FamilyActivity(
            memberID: UUID(), // Current user
            memberName: "You",
            type: .checkedIn,
            message: "Completed \(session.routineName) (\(Int(session.actualDuration / 60)) min)"
        )
        activityFeed.insert(activity, at: 0)
        
        // Send push notification to family members
        notifyFamilyMembers(about: activity)
    }
    
    /// Share a streak milestone
    func shareStreakMilestone(days: Int) {
        let activity = FamilyActivity(
            memberID: UUID(),
            memberName: "You",
            type: .celebratedAchievement,
            message: "Reached a \(days) day streak! 🔥"
        )
        activityFeed.insert(activity, at: 0)
        notifyFamilyMembers(about: activity)
    }
    
    /// Share an achievement
    func shareAchievement(type: AchievementType) {
        let activity = FamilyActivity(
            memberID: UUID(),
            memberName: "You",
            type: .celebratedAchievement,
            message: "Earned: \(type.title) - \(type.description)"
        )
        activityFeed.insert(activity, at: 0)
        notifyFamilyMembers(about: activity)
    }
    
    // MARK: - Encouragement
    
    /// Send encouragement to a family member
    func sendEncouragement(to member: FamilyMember, message: String, emoji: String = "👏") {
        let encouragement = EncouragementMessage(
            senderID: UUID(), // Current user
            senderName: "You",
            message: message,
            emoji: emoji
        )
        
        let activity = FamilyActivity(
            memberID: member.id,
            memberName: member.name,
            type: .sentEncouragement,
            message: "\(emoji) \(message)"
        )
        
        // In production, send push notification
        activityFeed.insert(activity, at: 0)
        _ = encouragement // Used for sending to the member
    }
    
    // MARK: - Check-In
    
    /// Request a check-in from a family member
    func requestCheckIn(from member: FamilyMember) {
        member.lastCheckInDate = Date()
        
        let activity = FamilyActivity(
            memberID: member.id,
            memberName: member.name,
            type: .checkedIn,
            message: "Check-in requested"
        )
        activityFeed.insert(activity, at: 0)
    }
    
    /// Respond to a check-in request
    func respondToCheckIn(status: String) {
        let activity = FamilyActivity(
            memberID: UUID(),
            memberName: "You",
            type: .checkedIn,
            message: status
        )
        activityFeed.insert(activity, at: 0)
        notifyFamilyMembers(about: activity)
    }
    
    // MARK: - Private Helpers
    
    private func notifyFamilyMembers(about activity: FamilyActivity) {
        // In production, this would send push notifications via CloudKit or APNs
        for member in familyMembers where member.notifyOnWorkoutComplete {
            // Send notification based on activity type and member preferences
            print("Notifying \(member.name) about: \(activity.message ?? activity.type.rawValue)")
        }
    }
    
    // MARK: - Sample Data
    
    func loadSampleData() {
        familyMembers = [
            {
                let member = FamilyMember(
                    name: "Sarah",
                    email: "sarah@example.com",
                    relationship: .child,
                    role: .supporter
                )
                member.inviteStatus = .accepted
                member.avatarColor = "#E76F51"
                return member
            }(),
            {
                let member = FamilyMember(
                    name: "Mike",
                    email: "mike@example.com",
                    relationship: .child,
                    role: .viewer
                )
                member.inviteStatus = .accepted
                member.avatarColor = "#2A9D8F"
                return member
            }()
        ]
        
        activityFeed = [
            FamilyActivity(
                memberID: familyMembers[0].id,
                memberName: "Sarah",
                type: .sentEncouragement,
                message: "Keep it up! 💪"
            ),
            FamilyActivity(
                memberID: UUID(),
                memberName: "You",
                type: .checkedIn,
                message: "Completed Morning Balance Boost (10 min)"
            )
        ]
    }
}

// MARK: - Notification Preferences Helper
struct NotificationPreferences {
    var enablePushNotifications: Bool = true
    var workoutComplete: Bool = true
    var streakMilestone: Bool = true
    var missedWorkout: Bool = false
    var emergency: Bool = true
}

extension FamilyMember {
    var notificationPreferences: NotificationPreferences {
        NotificationPreferences(
            enablePushNotifications: true,
            workoutComplete: notifyOnWorkoutComplete,
            streakMilestone: notifyOnStreakMilestone,
            missedWorkout: notifyOnMissedWorkout,
            emergency: notifyOnEmergency
        )
    }
}
