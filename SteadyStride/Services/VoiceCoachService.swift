//
//  VoiceCoachService.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import AVFoundation
import Combine
import os

/// Voice coaching service using AVSpeechSynthesizer
/// Provides voice guidance during exercises with configurable speed and voice
@MainActor
class VoiceCoachService: NSObject, ObservableObject {
    
    // MARK: - Singleton
    static let shared = VoiceCoachService()
    
    // MARK: - Logger
    private let logger = Logger(subsystem: "com.steadystride.app", category: "VoiceCoach")
    
    // MARK: - Published Properties
    @Published var isSpeaking: Bool = false
    @Published var isEnabled: Bool = true
    @Published var voiceSpeed: VoiceSpeed = .normal
    @Published var selectedVoice: AVSpeechSynthesisVoice?
    @Published var volume: Float = 1.0
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var speechQueue: [String] = []
    private var isProcessingQueue: Bool = false
    
    // Available voices
    var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .sorted { $0.name < $1.name }
    }
    
    // MARK: - Initialization
    override private init() {
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
        selectDefaultVoice()
    }
    
    // MARK: - Setup
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            logger.error("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    private func selectDefaultVoice() {
        // Try to find a premium voice first
        if let premiumVoice = availableVoices.first(where: { $0.quality == .enhanced }) {
            selectedVoice = premiumVoice
        } else if let defaultVoice = AVSpeechSynthesisVoice(language: "en-US") {
            selectedVoice = defaultVoice
        }
    }
    
    // MARK: - Speech Methods
    
    /// Speak a message immediately
    func speak(_ text: String, priority: SpeechPriority = .normal) {
        guard isEnabled else { return }
        
        switch priority {
        case .immediate:
            // Stop current speech and speak immediately
            stopSpeaking()
            speakNow(text)
        case .high:
            // Add to front of queue
            speechQueue.insert(text, at: 0)
            processQueue()
        case .normal:
            // Add to back of queue
            speechQueue.append(text)
            processQueue()
        }
    }
    
    /// Speak exercise instructions with timing
    func speakExerciseInstructions(_ instructions: [VoiceInstruction], startTime: Date) {
        guard isEnabled else { return }
        
        for instruction in instructions {
            let delay = instruction.timeOffset
            
            Task {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                await MainActor.run {
                    self.speak(instruction.text, priority: instruction.type == .countdown ? .immediate : .normal)
                }
            }
        }
    }
    
    /// Stop all speech
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        speechQueue.removeAll()
        isSpeaking = false
        isProcessingQueue = false
    }
    
    /// Pause speech
    func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .word)
    }
    
    /// Resume speech
    func resumeSpeaking() {
        synthesizer.continueSpeaking()
    }
    
    // MARK: - Private Methods
    
    private func speakNow(_ text: String) {
        let utterance = createUtterance(for: text)
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    private func processQueue() {
        guard !isProcessingQueue, !speechQueue.isEmpty else { return }
        guard !synthesizer.isSpeaking else { return }
        
        isProcessingQueue = true
        
        if let text = speechQueue.first {
            speechQueue.removeFirst()
            speakNow(text)
        }
        
        isProcessingQueue = false
    }
    
    private func createUtterance(for text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = voiceSpeed.rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = volume
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.2
        
        if let voice = selectedVoice {
            utterance.voice = voice
        }
        
        return utterance
    }
    
    // MARK: - Preset Messages
    
    /// Speak a countdown
    func speakCountdown(from number: Int, completion: @escaping () -> Void) {
        guard isEnabled else {
            completion()
            return
        }
        
        var count = number
        
        func countDown() {
            if count > 0 {
                speak("\(count)", priority: .immediate)
                count -= 1
                
                Task {
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    await MainActor.run {
                        countDown()
                    }
                }
            } else {
                speak("Go!", priority: .immediate)
                completion()
            }
        }
        
        countDown()
    }
    
    /// Encouragement phrases
    func speakEncouragement() {
        let phrases = [
            "Great job! Keep going!",
            "You're doing wonderful!",
            "Excellent form!",
            "That's it, nice and steady.",
            "Wonderful work!",
            "You've got this!",
            "Keep up the great effort!",
            "Beautiful! Almost there!"
        ]
        
        if let phrase = phrases.randomElement() {
            speak(phrase)
        }
    }
    
    /// Speak exercise start
    func speakExerciseStart(name: String, duration: TimeInterval) {
        let durationText = duration >= 60 ? "\(Int(duration / 60)) minute" : "\(Int(duration)) seconds"
        speak("Starting \(name). This exercise is \(durationText).")
    }
    
    /// Speak exercise complete
    func speakExerciseComplete() {
        let phrases = [
            "Exercise complete. Take a moment to rest.",
            "Well done! Rest and get ready for the next exercise.",
            "Great work! Catch your breath.",
            "Excellent! Rest up."
        ]
        
        if let phrase = phrases.randomElement() {
            speak(phrase)
        }
    }
    
    /// Speak workout complete
    func speakWorkoutComplete() {
        speak("Congratulations! You've completed your workout. Great job today!")
    }
    
    /// Speak rest period
    func speakRestPeriod(seconds: Int) {
        speak("Rest for \(seconds) seconds.")
    }
    
    /// Speak halfway point
    func speakHalfway() {
        speak("You're halfway there!")
    }
    
    /// Speak posture reminder
    func speakPostureReminder() {
        let reminders = [
            "Remember to keep your back straight.",
            "Check your posture.",
            "Keep your shoulders relaxed.",
            "Stand tall and steady."
        ]
        
        if let reminder = reminders.randomElement() {
            speak(reminder)
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension VoiceCoachService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.processQueue()
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = true
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}

// MARK: - Speech Priority
enum SpeechPriority {
    case immediate  // Stops current speech
    case high       // Front of queue
    case normal     // Back of queue
}

// MARK: - Voice Settings
extension VoiceCoachService {
    /// Update voice settings from user preferences
    func updateSettings(speed: VoiceSpeed, enabled: Bool, volume: Float = 1.0) {
        self.voiceSpeed = speed
        self.isEnabled = enabled
        self.volume = volume
    }
}
