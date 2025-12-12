//
//  NotificationService.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import UserNotifications
import Combine

/// Service for managing local and push notifications
@MainActor
class NotificationService: ObservableObject {
    
    static let shared = NotificationService()
    
    @Published var isAuthorized: Bool = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Workout Reminders
    
    /// Schedule daily workout reminder
    func scheduleWorkoutReminder(at time: TimeOfDay, routineName: String) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Your Workout! 💪"
        content.body = "Your \(routineName) routine is ready. Let's stay steady today!"
        content.sound = .default
        content.categoryIdentifier = "WORKOUT_REMINDER"
        
        var dateComponents = DateComponents()
        switch time {
        case .morning:
            dateComponents.hour = 8
            dateComponents.minute = 0
        case .afternoon:
            dateComponents.hour = 14
            dateComponents.minute = 0
        case .evening:
            dateComponents.hour = 18
            dateComponents.minute = 0
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "workout-reminder-\(time.rawValue)",
            content: content,
            trigger: trigger
        )
        
        try? await notificationCenter.add(request)
    }
    
    /// Cancel workout reminder
    func cancelWorkoutReminder(for time: TimeOfDay) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: ["workout-reminder-\(time.rawValue)"]
        )
    }
    
    // MARK: - Streak Reminders
    
    /// Schedule reminder to maintain streak
    func scheduleStreakReminder(currentStreak: Int) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak! 🔥"
        content.body = "You have a \(currentStreak) day streak. Complete today's workout to keep it going!"
        content.sound = .default
        content.categoryIdentifier = "STREAK_REMINDER"
        
        // Schedule for 7 PM if user hasn't worked out
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "streak-reminder",
            content: content,
            trigger: trigger
        )
        
        try? await notificationCenter.add(request)
    }
    
    // MARK: - Achievement Notifications
    
    /// Send immediate notification for achievement
    func notifyAchievement(_ type: AchievementType) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🏆"
        content.body = "\(type.title) - \(type.description)"
        content.sound = .default
        content.categoryIdentifier = "ACHIEVEMENT"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "achievement-\(type.rawValue)",
            content: content,
            trigger: trigger
        )
        
        try? await notificationCenter.add(request)
    }
    
    // MARK: - Family Notifications
    
    /// Notify about family member activity
    func notifyFamilyActivity(title: String, body: String) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "FAMILY"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "family-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        try? await notificationCenter.add(request)
    }
    
    // MARK: - Encouragement Notifications
    
    /// Schedule motivational notifications
    func scheduleMotivationalNotification() async {
        guard isAuthorized else { return }
        
        let messages = [
            ("You're doing great! 🌟", "Every step towards better mobility counts."),
            ("Time to move! 🚶", "A short exercise can boost your energy."),
            ("Stay steady! ⚖️", "Balance exercises help prevent falls."),
            ("Keep it up! 💪", "Consistency is the key to progress.")
        ]
        
        let message = messages.randomElement()!
        
        let content = UNMutableNotificationContent()
        content.title = message.0
        content.body = message.1
        content.sound = .default
        content.categoryIdentifier = "MOTIVATION"
        
        // Random time in the afternoon
        var dateComponents = DateComponents()
        dateComponents.hour = Int.random(in: 12...16)
        dateComponents.minute = Int.random(in: 0...59)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "motivation-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        try? await notificationCenter.add(request)
    }
    
    // MARK: - Management
    
    /// Clear all pending notifications
    func clearAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    /// Get all pending notifications
    func getPendingNotifications() async {
        pendingNotifications = await notificationCenter.pendingNotificationRequests()
    }
    
    // MARK: - Notification Categories
    
    func registerNotificationCategories() {
        // Workout reminder actions
        let startAction = UNNotificationAction(
            identifier: "START_WORKOUT",
            title: "Start Workout",
            options: [.foreground]
        )
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_WORKOUT",
            title: "Remind in 1 hour",
            options: []
        )
        
        let workoutCategory = UNNotificationCategory(
            identifier: "WORKOUT_REMINDER",
            actions: [startAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Achievement actions
        let shareAction = UNNotificationAction(
            identifier: "SHARE_ACHIEVEMENT",
            title: "Share with Family",
            options: [.foreground]
        )
        
        let achievementCategory = UNNotificationCategory(
            identifier: "ACHIEVEMENT",
            actions: [shareAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([workoutCategory, achievementCategory])
    }
}
