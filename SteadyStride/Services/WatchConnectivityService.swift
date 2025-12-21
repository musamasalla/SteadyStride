//
//  WatchConnectivityService.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import WatchConnectivity
import Combine
import os

/// Service for managing Apple Watch connectivity
/// Handles real-time data sync between iPhone and Watch
@MainActor
class WatchConnectivityService: NSObject, ObservableObject {
    
    // MARK: - Singleton
    static let shared = WatchConnectivityService()
    
    // MARK: - Logger
    private let logger = Logger(subsystem: "com.steadystride.app", category: "WatchConnectivity")
    
    // MARK: - Published Properties
    @Published var isWatchPaired: Bool = false
    @Published var isWatchAppInstalled: Bool = false
    @Published var isReachable: Bool = false
    @Published var lastSyncDate: Date?
    @Published var currentHeartRate: Double?
    @Published var isWatchWorkoutActive: Bool = false
    
    // MARK: - Private Properties
    private var session: WCSession?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Message Types
    enum MessageType: String {
        case startWorkout = "startWorkout"
        case pauseWorkout = "pauseWorkout"
        case resumeWorkout = "resumeWorkout"
        case endWorkout = "endWorkout"
        case exerciseChange = "exerciseChange"
        case heartRateUpdate = "heartRateUpdate"
        case postureAlert = "postureAlert"
        case syncProgress = "syncProgress"
        case requestHeartRate = "requestHeartRate"
    }
    
    // MARK: - Initialization
    override private init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    // MARK: - Public Methods
    
    /// Check if Watch connectivity is available
    var isAvailable: Bool {
        WCSession.isSupported() && isWatchPaired && isWatchAppInstalled
    }
    
    /// Send a message to the Watch
    func sendMessage(_ type: MessageType, data: [String: Any] = [:], replyHandler: (([String: Any]) -> Void)? = nil) {
        guard let session = session, session.isReachable else {
            logger.warning("Watch is not reachable")
            return
        }
        
        var message = data
        message["type"] = type.rawValue
        message["timestamp"] = Date().timeIntervalSince1970
        
        session.sendMessage(message, replyHandler: replyHandler) { [weak self] error in
            self?.logger.error("Error sending message to Watch: \(error.localizedDescription)")
        }
    }
    
    /// Transfer data to Watch (for when not immediately reachable)
    func transferUserInfo(_ userInfo: [String: Any]) {
        guard let session = session else { return }
        session.transferUserInfo(userInfo)
    }
    
    /// Update application context (latest data that Watch should have)
    func updateApplicationContext(_ context: [String: Any]) {
        guard let session = session else { return }
        
        do {
            try session.updateApplicationContext(context)
        } catch {
            logger.error("Error updating application context: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Workout Control
    
    /// Start a workout on the Watch
    func startWatchWorkout(routineName: String, exercises: [String]) {
        let data: [String: Any] = [
            "routineName": routineName,
            "exercises": exercises,
            "startTime": Date().timeIntervalSince1970
        ]
        
        sendMessage(.startWorkout, data: data)
        isWatchWorkoutActive = true
    }
    
    /// Pause the current Watch workout
    func pauseWatchWorkout() {
        sendMessage(.pauseWorkout)
    }
    
    /// Resume the current Watch workout
    func resumeWatchWorkout() {
        sendMessage(.resumeWorkout)
    }
    
    /// End the current Watch workout
    func endWatchWorkout() {
        sendMessage(.endWorkout)
        isWatchWorkoutActive = false
    }
    
    /// Notify Watch of exercise change
    func notifyExerciseChange(exerciseName: String, duration: TimeInterval, instructions: String) {
        let data: [String: Any] = [
            "exerciseName": exerciseName,
            "duration": duration,
            "instructions": instructions
        ]
        
        sendMessage(.exerciseChange, data: data)
    }
    
    /// Request heart rate update from Watch
    func requestHeartRateUpdate() {
        sendMessage(.requestHeartRate) { [weak self] reply in
            if let heartRate = reply["heartRate"] as? Double {
                Task { @MainActor in
                    self?.currentHeartRate = heartRate
                }
            }
        }
    }
    
    // MARK: - Posture Alerts
    
    /// Send posture alert to Watch (triggers haptic)
    func sendPostureAlert(message: String) {
        let data: [String: Any] = [
            "message": message,
            "vibrate": true
        ]
        
        sendMessage(.postureAlert, data: data)
    }
    
    // MARK: - Progress Sync
    
    /// Sync progress data to Watch
    func syncProgress(streak: Int, todayCompleted: Bool, weeklyProgress: [String: Bool]) {
        let context: [String: Any] = [
            "streak": streak,
            "todayCompleted": todayCompleted,
            "weeklyProgress": weeklyProgress,
            "lastSync": Date().timeIntervalSince1970
        ]
        
        updateApplicationContext(context)
        lastSyncDate = Date()
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            if activationState == .activated {
                self.isWatchPaired = session.isPaired
                self.isWatchAppInstalled = session.isWatchAppInstalled
                self.isReachable = session.isReachable
            }
            
            if let error = error {
                logger.error("WCSession activation failed: \(error.localizedDescription)")
            }
        }
    }
    
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Reactivate session after deactivation
        session.activate()
    }
    
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in
            handleReceivedMessage(message)
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task { @MainActor in
            handleReceivedMessage(message, replyHandler: replyHandler)
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        Task { @MainActor in
            handleReceivedUserInfo(userInfo)
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            handleReceivedApplicationContext(applicationContext)
        }
    }
}

// MARK: - Message Handling
extension WatchConnectivityService {
    private func handleReceivedMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        guard let typeString = message["type"] as? String,
              let type = MessageType(rawValue: typeString) else {
            return
        }
        
        switch type {
        case .heartRateUpdate:
            if let heartRate = message["heartRate"] as? Double {
                currentHeartRate = heartRate
            }
            
        case .postureAlert:
            // Handle posture alert from Watch (if Watch detects poor posture)
            if let alertMessage = message["message"] as? String {
                NotificationCenter.default.post(
                    name: .watchPostureAlert,
                    object: nil,
                    userInfo: ["message": alertMessage]
                )
            }
            
        case .endWorkout:
            // Watch ended the workout
            isWatchWorkoutActive = false
            if let summary = message["summary"] as? [String: Any] {
                NotificationCenter.default.post(
                    name: .watchWorkoutEnded,
                    object: nil,
                    userInfo: summary
                )
            }
            
        default:
            break
        }
        
        replyHandler?(["received": true])
    }
    
    private func handleReceivedUserInfo(_ userInfo: [String: Any]) {
        // Handle user info received from Watch
        if let workoutData = userInfo["workoutData"] as? [String: Any] {
            NotificationCenter.default.post(
                name: .watchWorkoutDataReceived,
                object: nil,
                userInfo: workoutData
            )
        }
    }
    
    private func handleReceivedApplicationContext(_ context: [String: Any]) {
        // Handle updated application context from Watch
        if let heartRate = context["currentHeartRate"] as? Double {
            currentHeartRate = heartRate
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let watchPostureAlert = Notification.Name("watchPostureAlert")
    static let watchWorkoutEnded = Notification.Name("watchWorkoutEnded")
    static let watchWorkoutDataReceived = Notification.Name("watchWorkoutDataReceived")
}
