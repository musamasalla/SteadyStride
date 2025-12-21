//
//  WorkoutViewModel.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class WorkoutViewModel {
    
    // MARK: - State
    var routine: Routine?
    var exercises: [Exercise] = []
    var currentExerciseIndex: Int = 0
    var isWorkoutActive: Bool = false
    var isPaused: Bool = false
    var isResting: Bool = false
    
    // MARK: - Timer
    var exerciseTimeRemaining: TimeInterval = 0
    var restTimeRemaining: TimeInterval = 0
    var totalElapsedTime: TimeInterval = 0
    
    // MARK: - Session Tracking
    var completedExerciseIDs: [UUID] = []
    var skippedExerciseIDs: [UUID] = []
    var sessionStartTime: Date?
    var heartRateSamples: [HeartRateSample] = []
    
    // MARK: - Timer
    private var timer: Timer?
    
    // MARK: - Computed Properties
    var currentExercise: Exercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(completedExerciseIDs.count) / Double(exercises.count)
    }
    
    var isLastExercise: Bool {
        currentExerciseIndex >= exercises.count - 1
    }
    
    var formattedTimeRemaining: String {
        let time = isResting ? restTimeRemaining : exerciseTimeRemaining
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedTotalTime: String {
        let minutes = Int(totalElapsedTime) / 60
        let seconds = Int(totalElapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Workout Control
    func startWorkout(routine: Routine, modelContext: ModelContext) {
        self.routine = routine
        
        // Load exercises for this routine from database
        if !routine.exerciseIDs.isEmpty {
            let exerciseIDStrings = routine.exerciseIDs.map { $0.uuidString }
            let descriptor = FetchDescriptor<Exercise>()
            let allExercises = (try? modelContext.fetch(descriptor)) ?? []
            
            // Filter and order by routine's exerciseIDs
            self.exercises = routine.exerciseIDs.compactMap { id in
                allExercises.first { $0.id == id }
            }
        }
        
        // Fallback to sample exercises if none loaded
        if exercises.isEmpty {
            self.exercises = Array(Exercise.sampleExercises.prefix(5))
        }
        
        self.currentExerciseIndex = 0
        self.completedExerciseIDs = []
        self.skippedExerciseIDs = []
        self.sessionStartTime = Date()
        self.isWorkoutActive = true
        self.isPaused = false
        
        startCurrentExercise()
        
        // Notify Watch
        WatchConnectivityService.shared.startWatchWorkout(
            routineName: routine.name,
            exercises: exercises.map { $0.name }
        )
    }
    
    func startCurrentExercise() {
        guard let exercise = currentExercise else {
            completeWorkout()
            return
        }
        
        exerciseTimeRemaining = exercise.duration
        isResting = false
        startTimer()
        
        // Voice guidance
        VoiceCoachService.shared.speakExerciseStart(
            name: exercise.name,
            duration: exercise.duration
        )
        
        // Notify Watch
        WatchConnectivityService.shared.notifyExerciseChange(
            exerciseName: exercise.name,
            duration: exercise.duration,
            instructions: exercise.instructions.first ?? ""
        )
    }
    
    func pauseWorkout() {
        isPaused = true
        stopTimer()
        WatchConnectivityService.shared.pauseWatchWorkout()
    }
    
    func resumeWorkout() {
        isPaused = false
        startTimer()
        WatchConnectivityService.shared.resumeWatchWorkout()
    }
    
    func skipExercise() {
        if let exercise = currentExercise {
            skippedExerciseIDs.append(exercise.id)
        }
        moveToNextExercise()
    }
    
    func completeExercise() {
        if let exercise = currentExercise {
            completedExerciseIDs.append(exercise.id)
        }
        
        VoiceCoachService.shared.speakExerciseComplete()
        
        if isLastExercise {
            completeWorkout()
        } else {
            startRestPeriod()
        }
    }
    
    func startRestPeriod() {
        guard let routine = routine else { return }
        restTimeRemaining = routine.restBetweenExercises
        isResting = true
        VoiceCoachService.shared.speakRestPeriod(seconds: Int(routine.restBetweenExercises))
    }
    
    func moveToNextExercise() {
        currentExerciseIndex += 1
        startCurrentExercise()
    }
    
    func completeWorkout() {
        stopTimer()
        isWorkoutActive = false
        VoiceCoachService.shared.speakWorkoutComplete()
        WatchConnectivityService.shared.endWatchWorkout()
    }
    
    func cancelWorkout() {
        stopTimer()
        isWorkoutActive = false
        WatchConnectivityService.shared.endWatchWorkout()
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.timerTick()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timerTick() {
        guard !isPaused else { return }
        
        totalElapsedTime += 1
        
        if isResting {
            restTimeRemaining -= 1
            if restTimeRemaining <= 0 {
                moveToNextExercise()
            }
        } else {
            exerciseTimeRemaining -= 1
            
            // Speak halfway
            if let exercise = currentExercise,
               exerciseTimeRemaining == exercise.duration / 2 {
                VoiceCoachService.shared.speakHalfway()
            }
            
            if exerciseTimeRemaining <= 0 {
                completeExercise()
            }
        }
    }
    
    // MARK: - Save Session
    func saveSession(modelContext: ModelContext) -> WorkoutSession? {
        guard let routine = routine, let startTime = sessionStartTime else { return nil }
        
        let session = WorkoutSession(routineID: routine.id, routineName: routine.name)
        session.startTime = startTime
        session.endTime = Date()
        session.actualDuration = totalElapsedTime
        session.completedExerciseIDs = completedExerciseIDs
        session.skippedExerciseIDs = skippedExerciseIDs
        session.totalExercises = exercises.count
        session.completionPercentage = progress
        session.status = .completed
        session.heartRateSamples = heartRateSamples
        
        modelContext.insert(session)
        return session
    }
}
