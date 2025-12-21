//
//  WatchHeartRateView.swift
//  SteadyStride Watch App
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import HealthKit

/// Heart rate monitoring view for Apple Watch
struct WatchHeartRateView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @State private var heartRate: Double = 0
    @State private var isMonitoring: Bool = false
    @State private var heartRateHistory: [Double] = []
    @State private var currentQuery: HKAnchoredObjectQuery?
    
    private let healthStore = HKHealthStore()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Heart Icon with Animation
                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .scaleEffect(isMonitoring ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isMonitoring)
                
                // Current Heart Rate
                if heartRate > 0 {
                    Text("\(Int(heartRate))")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("BPM")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text("--")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text("BPM")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Heart Rate Zone
                if heartRate > 0 {
                    Text(heartRateZone)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(heartRateZoneColor.opacity(0.3))
                        .cornerRadius(8)
                }
                
                // Start/Stop Button
                Button {
                    toggleMonitoring()
                } label: {
                    Label(isMonitoring ? "Stop" : "Start", systemImage: isMonitoring ? "stop.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(isMonitoring ? .red : .teal)
            }
        }
        .navigationTitle("Heart Rate")
        .onAppear {
            requestHealthKitPermission()
        }
        .onDisappear {
            stopHeartRateQuery()
        }
    }
    
    private var heartRateZone: String {
        switch heartRate {
        case ..<60: return "Resting"
        case 60..<100: return "Normal"
        case 100..<140: return "Moderate"
        case 140...: return "Intense"
        default: return ""
        }
    }
    
    private var heartRateZoneColor: Color {
        switch heartRate {
        case ..<60: return .blue
        case 60..<100: return .green
        case 100..<140: return .yellow
        case 140...: return .red
        default: return .gray
        }
    }
    
    private func requestHealthKitPermission() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if success {
                // Permission granted
            }
        }
    }
    
    private func toggleMonitoring() {
        isMonitoring.toggle()
        
        if isMonitoring {
            startHeartRateQuery()
        } else {
            stopHeartRateQuery()
        }
    }
    
    private func startHeartRateQuery() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { query, samples, deletedObjects, anchor, error in
            updateHeartRate(from: samples)
        }
        
        query.updateHandler = { query, samples, deletedObjects, anchor, error in
            updateHeartRate(from: samples)
        }
        
        currentQuery = query
        healthStore.execute(query)
    }
    
    private func stopHeartRateQuery() {
        if let query = currentQuery {
            healthStore.stop(query)
            currentQuery = nil
        }
        isMonitoring = false
    }
    
    private func updateHeartRate(from samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample],
              let latestSample = samples.last else { return }
        
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let value = latestSample.quantity.doubleValue(for: heartRateUnit)
        
        Task { @MainActor in
            heartRate = value
            heartRateHistory.append(value)
            connectivity.sendHeartRateUpdate(value)
        }
    }
}

#Preview {
    WatchHeartRateView()
        .environment(WatchConnectivityManager.shared)
}
