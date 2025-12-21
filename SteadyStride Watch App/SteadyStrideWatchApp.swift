//
//  SteadyStrideWatchApp.swift
//  SteadyStride Watch App
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import WatchConnectivity

@main
struct SteadyStrideWatchApp: App {
    @State private var connectivityManager = WatchConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            WatchHomeView()
                .environment(connectivityManager)
        }
    }
}

// MARK: - Watch Connectivity Manager
@Observable
class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()
    
    var isPhoneReachable: Bool = false
    var currentStreak: Int = 0
    var todayComplete: Bool = false
    var currentHeartRate: Double = 0
    
    private var session: WCSession?
    
    override private init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    // MARK: - Send to Phone
    func sendWorkoutComplete(duration: TimeInterval, exercisesCompleted: Int) {
        guard let session = session, session.isReachable else { return }
        
        let message: [String: Any] = [
            "type": "workoutComplete",
            "duration": duration,
            "exercisesCompleted": exercisesCompleted,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        session.sendMessage(message, replyHandler: nil)
    }
    
    func sendHeartRateUpdate(_ heartRate: Double) {
        guard let session = session, session.isReachable else { return }
        
        session.sendMessage([
            "type": "heartRateUpdate",
            "heartRate": heartRate
        ], replyHandler: nil)
    }
    
    func requestSync() {
        guard let session = session, session.isReachable else { return }
        session.sendMessage(["type": "requestSync"], replyHandler: nil)
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            isPhoneReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            isPhoneReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in
            handleMessage(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            if let streak = applicationContext["streak"] as? Int {
                currentStreak = streak
            }
            if let complete = applicationContext["todayCompleted"] as? Bool {
                todayComplete = complete
            }
        }
    }
    
    private func handleMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }
        
        switch type {
        case "startWorkout":
            // Handle workout start from phone
            NotificationCenter.default.post(name: .startWorkoutFromPhone, object: message)
        case "syncProgress":
            if let streak = message["streak"] as? Int {
                currentStreak = streak
            }
            if let complete = message["todayCompleted"] as? Bool {
                todayComplete = complete
            }
        default:
            break
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let startWorkoutFromPhone = Notification.Name("startWorkoutFromPhone")
}
