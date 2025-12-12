//
//  HealthKitService.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import HealthKit
import Combine

/// Service for managing HealthKit integration
/// Handles reading health data and writing workout sessions
@MainActor
class HealthKitService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = HealthKitService()
    
    // MARK: - Published Properties
    @Published var isAuthorized: Bool = false
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var todaySteps: Int = 0
    @Published var todayActiveMinutes: Int = 0
    @Published var latestHeartRate: Double?
    @Published var weeklySteps: [Date: Int] = [:]
    
    // MARK: - Private Properties
    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()
    
    // Types we want to read
    private let readTypes: Set<HKObjectType> = {
        var types: Set<HKObjectType> = []
        
        // Quantity Types
        if let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepCount)
        }
        if let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            types.insert(heartRate)
        }
        if let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(activeEnergy)
        }
        if let exerciseMinutes = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) {
            types.insert(exerciseMinutes)
        }
        if let walkingSpeed = HKQuantityType.quantityType(forIdentifier: .walkingSpeed) {
            types.insert(walkingSpeed)
        }
        if let walkingStepLength = HKQuantityType.quantityType(forIdentifier: .walkingStepLength) {
            types.insert(walkingStepLength)
        }
        if let walkingAsymmetry = HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage) {
            types.insert(walkingAsymmetry)
        }
        
        // Category Types
        if let fallEvent = HKCategoryType.categoryType(forIdentifier: .appleWalkingSteadinessEvent) {
            types.insert(fallEvent)
        }
        
        return types
    }()
    
    // Types we want to write
    private let writeTypes: Set<HKSampleType> = {
        var types: Set<HKSampleType> = []
        
        if let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(activeEnergy)
        }
        
        types.insert(HKWorkoutType.workoutType())
        
        return types
    }()
    
    // MARK: - Initialization
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Check if HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    /// Request authorization to access HealthKit data
    func requestAuthorization() async throws {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        
        await MainActor.run {
            self.isAuthorized = true
            self.checkAuthorizationStatus()
        }
        
        // Start fetching data after authorization
        await fetchTodayData()
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        guard isHealthKitAvailable else {
            authorizationStatus = .notDetermined
            return
        }
        
        if let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            authorizationStatus = healthStore.authorizationStatus(for: stepType)
            isAuthorized = authorizationStatus == .sharingAuthorized
        }
    }
    
    // MARK: - Fetch Data
    
    /// Fetch today's health data
    func fetchTodayData() async {
        await fetchTodaySteps()
        await fetchTodayActiveMinutes()
        await fetchLatestHeartRate()
    }
    
    /// Fetch today's step count
    func fetchTodaySteps() async {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        do {
            let steps = try await fetchSum(for: stepType, predicate: predicate, unit: .count())
            await MainActor.run {
                self.todaySteps = Int(steps)
            }
        } catch {
            print("Error fetching steps: \(error)")
        }
    }
    
    /// Fetch today's active minutes
    func fetchTodayActiveMinutes() async {
        guard let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        do {
            let minutes = try await fetchSum(for: exerciseType, predicate: predicate, unit: .minute())
            await MainActor.run {
                self.todayActiveMinutes = Int(minutes)
            }
        } catch {
            print("Error fetching active minutes: \(error)")
        }
    }
    
    /// Fetch latest heart rate
    func fetchLatestHeartRate() async {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        do {
            let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
                let query = HKSampleQuery(
                    sampleType: heartRateType,
                    predicate: nil,
                    limit: 1,
                    sortDescriptors: [sortDescriptor]
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: samples ?? [])
                    }
                }
                healthStore.execute(query)
            }
            
            if let sample = samples.first as? HKQuantitySample {
                let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                await MainActor.run {
                    self.latestHeartRate = heartRate
                }
            }
        } catch {
            print("Error fetching heart rate: \(error)")
        }
    }
    
    /// Fetch weekly steps
    func fetchWeeklySteps() async -> [Date: Int] {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return [:] }
        
        let calendar = Calendar.current
        let now = Date()
        var weeklySteps: [Date: Int] = [:]
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { continue }
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            do {
                let steps = try await fetchSum(for: stepType, predicate: predicate, unit: .count())
                weeklySteps[startOfDay] = Int(steps)
            } catch {
                print("Error fetching steps for \(date): \(error)")
            }
        }
        
        await MainActor.run {
            self.weeklySteps = weeklySteps
        }
        
        return weeklySteps
    }
    
    // MARK: - Save Workout
    
    /// Save a workout session to HealthKit
    func saveWorkout(
        duration: TimeInterval,
        calories: Double,
        startDate: Date,
        endDate: Date
    ) async throws {
        let workout = HKWorkout(
            activityType: .functionalStrengthTraining,
            start: startDate,
            end: endDate,
            duration: duration,
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
            totalDistance: nil,
            metadata: [
                HKMetadataKeyWorkoutBrandName: "SteadyStride",
                "WorkoutType": "Mobility Training"
            ]
        )
        
        try await healthStore.save(workout)
    }
    
    // MARK: - Walking Steadiness
    
    /// Fetch walking steadiness score if available (iOS 15+)
    func fetchWalkingSteadiness() async -> Double? {
        guard let steadinessType = HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness) else {
            return nil
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        do {
            let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
                let query = HKSampleQuery(
                    sampleType: steadinessType,
                    predicate: nil,
                    limit: 1,
                    sortDescriptors: [sortDescriptor]
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: samples ?? [])
                    }
                }
                healthStore.execute(query)
            }
            
            if let sample = samples.first as? HKQuantitySample {
                return sample.quantity.doubleValue(for: .percent()) * 100
            }
        } catch {
            print("Error fetching walking steadiness: \(error)")
        }
        
        return nil
    }
    
    // MARK: - Helper Methods
    
    private func fetchSum(for quantityType: HKQuantityType, predicate: NSPredicate, unit: HKUnit) async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let sum = statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: sum)
            }
            
            healthStore.execute(query)
        }
    }
}

// MARK: - Errors
enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationDenied
    case dataNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device."
        case .authorizationDenied:
            return "HealthKit authorization was denied."
        case .dataNotAvailable:
            return "The requested health data is not available."
        }
    }
}

// MARK: - Heart Rate Sample Extension
extension HeartRateSample {
    init(from hkSample: HKQuantitySample) {
        self.id = UUID()
        self.timestamp = hkSample.endDate
        self.beatsPerMinute = hkSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        self.source = .appleWatch
    }
}
