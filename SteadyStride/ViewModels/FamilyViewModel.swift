//
//  FamilyViewModel.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class FamilyViewModel {
    
    // MARK: - State
    var isLoading: Bool = false
    var showingInviteSheet: Bool = false
    var showingMemberDetail: Bool = false
    var selectedMember: FamilyMember?
    
    // MARK: - Invite Form
    var inviteName: String = ""
    var inviteEmail: String = ""
    var inviteRelationship: FamilyRelationship = .other
    var inviteRole: FamilyRole = .viewer
    
    // MARK: - Data
    var familyMembers: [FamilyMember] = []
    var pendingInvites: [FamilyMember] = []
    var activityFeed: [FamilyActivity] = []
    
    // MARK: - Computed
    var hasFamily: Bool {
        !familyMembers.isEmpty || !pendingInvites.isEmpty
    }
    
    var acceptedMembers: [FamilyMember] {
        familyMembers.filter { $0.inviteStatus == .accepted }
    }
    
    // MARK: - Load Data
    func loadFamilyData() {
        isLoading = true
        
        let service = FamilySharingService.shared
        familyMembers = service.familyMembers
        pendingInvites = service.pendingInvites
        activityFeed = service.activityFeed
        
        isLoading = false
    }
    
    func loadSampleData() {
        FamilySharingService.shared.loadSampleData()
        loadFamilyData()
    }
    
    // MARK: - Invite Actions
    func sendInvite() async {
        guard isValidInvite else { return }
        
        isLoading = true
        
        do {
            let member = try await FamilySharingService.shared.inviteFamilyMember(
                name: inviteName,
                email: inviteEmail,
                relationship: inviteRelationship,
                role: inviteRole
            )
            pendingInvites.append(member)
            resetInviteForm()
            showingInviteSheet = false
        } catch {
            print("Failed to send invite: \(error)")
        }
        
        isLoading = false
    }
    
    func cancelInvite(for member: FamilyMember) {
        FamilySharingService.shared.removeFamilyMember(member)
        pendingInvites.removeAll { $0.id == member.id }
    }
    
    var isValidInvite: Bool {
        !inviteName.isEmpty && isValidEmail(inviteEmail)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    private func resetInviteForm() {
        inviteName = ""
        inviteEmail = ""
        inviteRelationship = .other
        inviteRole = .viewer
    }
    
    // MARK: - Member Actions
    func removeMember(_ member: FamilyMember) {
        FamilySharingService.shared.removeFamilyMember(member)
        familyMembers.removeAll { $0.id == member.id }
    }
    
    func updateRole(for member: FamilyMember, role: FamilyRole) {
        FamilySharingService.shared.updateRole(for: member, role: role)
    }
    
    func selectMember(_ member: FamilyMember) {
        selectedMember = member
        showingMemberDetail = true
    }
    
    // MARK: - Encouragement
    func sendEncouragement(to member: FamilyMember, message: String, emoji: String = "👏") {
        FamilySharingService.shared.sendEncouragement(to: member, message: message, emoji: emoji)
        loadFamilyData()
    }
    
    func requestCheckIn(from member: FamilyMember) {
        FamilySharingService.shared.requestCheckIn(from: member)
        loadFamilyData()
    }
    
    // MARK: - Activity
    var recentActivity: [FamilyActivity] {
        Array(activityFeed.prefix(10))
    }
    
    func refreshActivity() {
        activityFeed = FamilySharingService.shared.activityFeed
    }
}

// MARK: - Quick Encouragement Messages
extension FamilyViewModel {
    var quickEncouragementMessages: [(emoji: String, message: String)] {
        EncouragementMessage.presetMessages
    }
}
