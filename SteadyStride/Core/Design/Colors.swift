//
//  Colors.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

/// Color palette designed for senior users
/// - High contrast ratios for readability
/// - Calming, trustworthy colors
/// - Clear visual hierarchy
extension Color {
    
    // MARK: - Primary Colors
    
    /// Main brand color - Calming teal that conveys trust and health
    static let steadyPrimary = Color(hex: "2A9D8F")
    
    /// Darker variant for text and emphasis
    static let steadyPrimaryDark = Color(hex: "21867A")
    
    /// Light variant for backgrounds
    static let steadyPrimaryLight = Color(hex: "E8F5F3")
    
    // MARK: - Secondary Colors
    
    /// Warm orange for calls-to-action - energetic but not alarming
    static let steadySecondary = Color(hex: "E76F51")
    
    /// Darker variant for pressed states
    static let steadySecondaryDark = Color(hex: "D35D41")
    
    /// Light variant for subtle highlights
    static let steadySecondaryLight = Color(hex: "FDF0ED")
    
    // MARK: - Accent Colors
    
    /// Success green for achievements and completions
    static let steadySuccess = Color(hex: "06D6A0")
    
    /// Warning amber for alerts (not alarming)
    static let steadyWarning = Color(hex: "FFB703")
    
    /// Error red - used sparingly
    static let steadyError = Color(hex: "EF476F")
    
    /// Info blue for tips and guidance
    static let steadyInfo = Color(hex: "118AB2")
    
    // MARK: - Background Colors
    
    /// Soft cream background - easy on the eyes
    static let steadyBackground = Color(hex: "FDF6EC")
    
    /// Card background
    static let steadyCardBackground = Color(hex: "FFFFFF")
    
    /// Secondary background for sections
    static let steadyBackgroundSecondary = Color(hex: "F5EFE6")
    
    // MARK: - Text Colors
    
    /// Primary text - high contrast for readability
    static let steadyTextPrimary = Color(hex: "1D3557")
    
    /// Secondary text for descriptions
    static let steadyTextSecondary = Color(hex: "457B9D")
    
    /// Tertiary text for captions
    static let steadyTextTertiary = Color(hex: "8FA4B5")
    
    /// Text on primary colored backgrounds
    static let steadyTextOnPrimary = Color.white
    
    // MARK: - Semantic Colors
    
    /// Border color for inputs and cards
    static let steadyBorder = Color(hex: "E5E5E5")
    
    /// Divider color
    static let steadyDivider = Color(hex: "EEEEEE")
    
    /// Disabled state color
    static let steadyDisabled = Color(hex: "CCCCCC")
    
    // MARK: - Gradient Presets
    
    /// Primary gradient for buttons and headers
    static let steadyGradient = LinearGradient(
        colors: [steadyPrimary, steadyPrimaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Warm gradient for celebration moments
    static let celebrationGradient = LinearGradient(
        colors: [Color(hex: "FFB703"), Color(hex: "E76F51")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Health/vitality gradient
    static let vitalityGradient = LinearGradient(
        colors: [Color(hex: "06D6A0"), Color(hex: "2A9D8F")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Hex Color Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Dark Mode Support
extension Color {
    /// Adaptive primary color
    static func adaptivePrimary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? steadyPrimaryLight : steadyPrimary
    }
    
    /// Adaptive background
    static func adaptiveBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "1A1A2E") : steadyBackground
    }
    
    /// Adaptive card background
    static func adaptiveCardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "252538") : steadyCardBackground
    }
    
    /// Adaptive text primary
    static func adaptiveTextPrimary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : steadyTextPrimary
    }
}
