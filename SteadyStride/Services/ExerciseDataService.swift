//
//  ExerciseDataService.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation

/// Service for loading and managing exercise data
class ExerciseDataService {
    
    static let shared = ExerciseDataService()
    
    private init() {}
    
    // MARK: - Curated Exercise Database
    /// Complete list of exercises categorized for seniors
    var allExercises: [Exercise] {
        return balanceExercises + strengthExercises + flexibilityExercises + breathingExercises
    }
    
    // MARK: - Balance Exercises
    var balanceExercises: [Exercise] {
        [
            Exercise(
                name: "Single Leg Stand",
                description: "Improve your balance by standing on one leg while holding onto a chair for support.",
                category: .balance,
                difficulty: .easy,
                duration: 30,
                instructions: [
                    "Stand behind a sturdy chair, holding the back for support",
                    "Lift your right foot off the ground",
                    "Hold for 10-15 seconds",
                    "Lower your foot and repeat with the left leg",
                    "Aim for 10 repetitions on each leg"
                ],
                benefits: ["Improves balance", "Strengthens ankles", "Builds confidence"]
            ),
            Exercise(
                name: "Heel-to-Toe Walk",
                description: "Walk in a straight line placing your heel directly in front of your toes.",
                category: .balance,
                difficulty: .moderate,
                duration: 60,
                instructions: [
                    "Stand near a wall for support if needed",
                    "Place your right foot directly in front of your left",
                    "Your right heel should touch your left toes",
                    "Take 15-20 steps forward",
                    "Turn around and walk back"
                ],
                benefits: ["Improves gait", "Enhances coordination", "Reduces fall risk"]
            ),
            Exercise(
                name: "Weight Shifts",
                description: "Shift your weight from side to side to improve lateral balance.",
                category: .balance,
                difficulty: .easy,
                duration: 45,
                instructions: [
                    "Stand with feet hip-width apart",
                    "Shift your weight to your right foot",
                    "Lift your left foot slightly off the ground",
                    "Hold for 5 seconds",
                    "Return to center and repeat on the other side"
                ],
                benefits: ["Improves lateral stability", "Strengthens hip muscles"]
            )
        ]
    }
    
    // MARK: - Strength Exercises
    var strengthExercises: [Exercise] {
        [
            Exercise(
                name: "Chair Stand",
                description: "Build leg strength by standing up from a seated position without using your hands.",
                category: .strength,
                difficulty: .easy,
                duration: 45,
                instructions: [
                    "Sit in a sturdy chair with feet flat on the floor",
                    "Cross your arms over your chest",
                    "Keep your back straight and lean slightly forward",
                    "Stand up by pushing through your heels",
                    "Slowly sit back down with control",
                    "Repeat 10-15 times"
                ],
                benefits: ["Strengthens legs", "Improves mobility", "Builds functional strength"]
            ),
            Exercise(
                name: "Wall Push-Ups",
                description: "Strengthen your chest, shoulders and arms using the wall.",
                category: .strength,
                difficulty: .easy,
                duration: 60,
                instructions: [
                    "Stand facing a wall, about arm's length away",
                    "Place your palms flat on the wall at shoulder height",
                    "Bend your elbows and lean your body toward the wall",
                    "Push back to the starting position",
                    "Repeat 10-15 times"
                ],
                benefits: ["Strengthens upper body", "Improves posture", "Low impact"]
            ),
            Exercise(
                name: "Calf Raises",
                description: "Strengthen your calves by raising up onto your toes.",
                category: .strength,
                difficulty: .easy,
                duration: 45,
                instructions: [
                    "Stand behind a chair, holding the back for balance",
                    "Slowly rise up onto your toes",
                    "Hold for 2-3 seconds at the top",
                    "Lower back down slowly",
                    "Repeat 15-20 times"
                ],
                benefits: ["Strengthens calves", "Improves ankle stability", "Helps with walking"]
            )
        ]
    }
    
    // MARK: - Flexibility Exercises
    var flexibilityExercises: [Exercise] {
        [
            Exercise(
                name: "Neck Stretches",
                description: "Gently stretch your neck muscles to reduce tension.",
                category: .flexibility,
                difficulty: .easy,
                duration: 30,
                instructions: [
                    "Sit or stand with good posture",
                    "Slowly tilt your head to the right, ear toward shoulder",
                    "Hold for 15-30 seconds",
                    "Return to center",
                    "Repeat on the left side"
                ],
                benefits: ["Reduces neck tension", "Improves range of motion"]
            ),
            Exercise(
                name: "Shoulder Rolls",
                description: "Loosen up your shoulders with circular rolling motions.",
                category: .flexibility,
                difficulty: .easy,
                duration: 30,
                instructions: [
                    "Sit or stand with arms relaxed at your sides",
                    "Roll your shoulders forward in a circular motion",
                    "Complete 10 forward circles",
                    "Reverse direction for 10 backward circles"
                ],
                benefits: ["Relieves shoulder tension", "Improves upper body mobility"]
            ),
            Exercise(
                name: "Seated Hamstring Stretch",
                description: "Stretch the backs of your thighs while seated.",
                category: .flexibility,
                difficulty: .easy,
                duration: 45,
                instructions: [
                    "Sit on the edge of a chair",
                    "Extend your right leg straight out with heel on floor",
                    "Keep your left foot flat on the floor",
                    "Lean forward slightly from your hips",
                    "Hold for 20-30 seconds",
                    "Switch legs"
                ],
                benefits: ["Stretches hamstrings", "Reduces lower back tension"]
            )
        ]
    }
    
    // MARK: - Breathing Exercises
    var breathingExercises: [Exercise] {
        [
            Exercise(
                name: "Deep Breathing",
                description: "Practice deep, diaphragmatic breathing for relaxation.",
                category: .breathing,
                difficulty: .easy,
                duration: 60,
                instructions: [
                    "Sit comfortably with your back supported",
                    "Place one hand on your chest, one on your belly",
                    "Breathe in slowly through your nose for 4 counts",
                    "Feel your belly rise as you inhale",
                    "Exhale slowly through your mouth for 6 counts",
                    "Repeat 5-10 times"
                ],
                benefits: ["Reduces stress", "Lowers blood pressure", "Promotes relaxation"]
            ),
            Exercise(
                name: "Box Breathing",
                description: "A calming technique using equal-length breaths.",
                category: .breathing,
                difficulty: .easy,
                duration: 90,
                instructions: [
                    "Sit in a comfortable position",
                    "Inhale for 4 counts",
                    "Hold your breath for 4 counts",
                    "Exhale for 4 counts",
                    "Hold empty for 4 counts",
                    "Repeat the cycle 4-6 times"
                ],
                benefits: ["Calms the nervous system", "Improves focus", "Reduces anxiety"]
            )
        ]
    }
    
    // MARK: - Routines
    var morningRoutine: Routine {
        Routine(
            name: "Morning Energy Boost",
            description: "A gentle routine to start your day with energy and focus.",
            category: .balance,
            targetMobilityLevel: .beginner,
            difficulty: .easy
        )
    }
    
    var balanceBoostRoutine: Routine {
        Routine(
            name: "Balance Builder",
            description: "Focused exercises to improve your balance and stability.",
            category: .balance,
            targetMobilityLevel: .beginner,
            difficulty: .moderate
        )
    }
    
    var strengthRoutine: Routine {
        Routine(
            name: "Strength & Stability",
            description: "Build functional strength for everyday activities.",
            category: .strength,
            targetMobilityLevel: .intermediate,
            difficulty: .moderate
        )
    }
}
