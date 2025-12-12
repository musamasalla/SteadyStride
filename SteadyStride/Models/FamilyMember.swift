//
//  FamilyMember.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftData

// MARK: - Family Member Model
@Model
final class FamilyMember {
    var id: UUID
    var name: String
    var email: String
    var relationship: FamilyRelationship
    var role: FamilyRole
    
    // Permissions
    var canViewProgress: Bool
    var canReceiveAlerts: Bool
    var canSendEncouragement: Bool
    var canViewLocation: Bool
    
    // Status
    var inviteStatus: InviteStatus
    var inviteSentDate: Date?
    var inviteAcceptedDate: Date?
    var lastCheckInDate: Date?
    
    // Notification Preferences
    var notifyOnWorkoutComplete: Bool
    var notifyOnStreakMilestone: Bool
    var notifyOnMissedWorkout: Bool
    var notifyOnEmergency: Bool
    
    // Avatar
    var profileImageData: Data?
    var avatarColor: String
    
    init(
        name: String,
        email: String,
        relationship: FamilyRelationship,
        role: FamilyRole = .viewer
    ) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.relationship = relationship
        self.role = role
        self.canViewProgress = true
        self.canReceiveAlerts = true
        self.canSendEncouragement = true
        self.canViewLocation = false
        self.inviteStatus = .pending
        self.inviteSentDate = Date()
        self.notifyOnWorkoutComplete = true
        self.notifyOnStreakMilestone = true
        self.notifyOnMissedWorkout = false
        self.notifyOnEmergency = true
        self.avatarColor = FamilyMember.randomColor()
    }
    
    static func randomColor() -> String {
        let colors = ["2A9D8F", "E76F51", "F4A261", "E9C46A", "264653", "118AB2", "06D6A0", "9B5DE5"]
        return colors.randomElement() ?? "2A9D8F"
    }
}

// MARK: - Family Relationship
enum FamilyRelationship: String, Codable, CaseIterable {
    case spouse = "Spouse/Partner"
    case child = "Son/Daughter"
    case sibling = "Sibling"
    case grandchild = "Grandchild"
    case friend = "Friend"
    case caregiver = "Caregiver"
    case healthcareProvider = "Healthcare Provider"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .spouse: return "heart.fill"
        case .child: return "figure.and.child.holdinghands"
        case .sibling: return "person.2.fill"
        case .grandchild: return "figure.2.and.child.holdinghands"
        case .friend: return "person.crop.circle.badge.checkmark"
        case .caregiver: return "cross.case.fill"
        case .healthcareProvider: return "stethoscope"
        case .other: return "person.crop.circle"
        }
    }
}

// MARK: - Family Role
enum FamilyRole: String, Codable, CaseIterable {
    case viewer = "Viewer"
    case supporter = "Supporter"
    case caregiver = "Caregiver"
    case admin = "Admin"
    
    var description: String {
        switch self {
        case .viewer:
            return "Can view progress and achievements"
        case .supporter:
            return "Can view progress and send encouragement"
        case .caregiver:
            return "Full access including alerts and detailed health data"
        case .admin:
            return "Can manage family settings and members"
        }
    }
    
    var permissions: [FamilyPermission] {
        switch self {
        case .viewer:
            return [.viewProgress, .viewAchievements]
        case .supporter:
            return [.viewProgress, .viewAchievements, .sendEncouragement]
        case .caregiver:
            return FamilyPermission.allCases
        case .admin:
            return FamilyPermission.allCases
        }
    }
}

// MARK: - Family Permission
enum FamilyPermission: String, Codable, CaseIterable {
    case viewProgress = "View Progress"
    case viewAchievements = "View Achievements"
    case sendEncouragement = "Send Encouragement"
    case receiveAlerts = "Receive Alerts"
    case viewHealthData = "View Health Data"
    case manageSettings = "Manage Settings"
}

// MARK: - Invite Status
enum InviteStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
    case expired = "Expired"
    
    var icon: String {
        switch self {
        case .pending: return "envelope.badge.fill"
        case .accepted: return "checkmark.circle.fill"
        case .declined: return "xmark.circle.fill"
        case .expired: return "clock.badge.exclamationmark.fill"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "FFB703"
        case .accepted: return "06D6A0"
        case .declined: return "EF476F"
        case .expired: return "8FA4B5"
        }
    }
}

// MARK: - Family Activity
struct FamilyActivity: Identifiable {
    let id: UUID
    let memberID: UUID
    let memberName: String
    let type: FamilyActivityType
    let timestamp: Date
    let message: String?
    
    init(memberID: UUID, memberName: String, type: FamilyActivityType, message: String? = nil) {
        self.id = UUID()
        self.memberID = memberID
        self.memberName = memberName
        self.type = type
        self.timestamp = Date()
        self.message = message
    }
}

// MARK: - Family Activity Type
enum FamilyActivityType: String, Codable {
    case checkedIn = "Checked In"
    case sentEncouragement = "Sent Encouragement"
    case viewedProgress = "Viewed Progress"
    case celebratedAchievement = "Celebrated Achievement"
    case joinedFamily = "Joined Family"
    
    var icon: String {
        switch self {
        case .checkedIn: return "eye.fill"
        case .sentEncouragement: return "hands.clap.fill"
        case .viewedProgress: return "chart.line.uptrend.xyaxis"
        case .celebratedAchievement: return "party.popper.fill"
        case .joinedFamily: return "person.badge.plus"
        }
    }
    
    var color: String {
        switch self {
        case .checkedIn: return "118AB2"
        case .sentEncouragement: return "E76F51"
        case .viewedProgress: return "2A9D8F"
        case .celebratedAchievement: return "FFB703"
        case .joinedFamily: return "06D6A0"
        }
    }
}

// MARK: - Encouragement Message
struct EncouragementMessage: Identifiable, Codable {
    let id: UUID
    let senderID: UUID
    let senderName: String
    let message: String
    let emoji: String
    let timestamp: Date
    var isRead: Bool
    
    init(senderID: UUID, senderName: String, message: String, emoji: String = "👏") {
        self.id = UUID()
        self.senderID = senderID
        self.senderName = senderName
        self.message = message
        self.emoji = emoji
        self.timestamp = Date()
        self.isRead = false
    }
    
    static let presetMessages = [
        ("👏", "Great job today!"),
        ("💪", "You're doing amazing!"),
        ("🌟", "So proud of you!"),
        ("❤️", "Keep up the great work!"),
        ("🎉", "Celebrating your progress!"),
        ("🙌", "You inspire me every day!"),
        ("⭐", "You're a superstar!"),
        ("🏆", "Champion effort!")
    ]
}
