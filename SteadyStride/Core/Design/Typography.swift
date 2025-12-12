//
//  Typography.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

/// Typography system designed for senior users
/// - Larger base font sizes
/// - Clear hierarchy
/// - Full Dynamic Type support
struct Typography {
    
    // MARK: - Display Fonts (Headers)
    
    /// Extra large display - for celebration screens
    static let displayLarge = Font.system(size: 40, weight: .bold, design: .rounded)
    
    /// Large display - for main screen titles
    static let displayMedium = Font.system(size: 32, weight: .bold, design: .rounded)
    
    /// Small display - for section headers
    static let displaySmall = Font.system(size: 28, weight: .semibold, design: .rounded)
    
    // MARK: - Headline Fonts
    
    /// Primary headline
    static let headlineLarge = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    /// Secondary headline
    static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    /// Small headline
    static let headlineSmall = Font.system(size: 18, weight: .medium, design: .rounded)
    
    // MARK: - Body Fonts
    
    /// Large body text - for primary content
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    
    /// Medium body text - standard content
    static let bodyMedium = Font.system(size: 16, weight: .regular, design: .default)
    
    /// Small body text - for less important info
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    // MARK: - Label Fonts
    
    /// Large labels for buttons
    static let labelLarge = Font.system(size: 18, weight: .semibold, design: .rounded)
    
    /// Medium labels
    static let labelMedium = Font.system(size: 16, weight: .medium, design: .rounded)
    
    /// Small labels for captions
    static let labelSmall = Font.system(size: 14, weight: .medium, design: .rounded)
    
    // MARK: - Caption Fonts
    
    /// Caption text
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    
    /// Overline text
    static let overline = Font.system(size: 11, weight: .semibold, design: .default)
    
    // MARK: - Special Fonts
    
    /// Timer display
    static let timer = Font.system(size: 64, weight: .bold, design: .monospaced)
    
    /// Counter display
    static let counter = Font.system(size: 48, weight: .bold, design: .rounded)
    
    /// Badge text
    static let badge = Font.system(size: 10, weight: .bold, design: .rounded)
}

// MARK: - Text Styles (Dynamic Type)
extension View {
    /// Apply display large style with Dynamic Type
    func displayLargeStyle() -> some View {
        self
            .font(.largeTitle)
            .fontWeight(.bold)
            .fontDesign(.rounded)
    }
    
    /// Apply display medium style with Dynamic Type
    func displayMediumStyle() -> some View {
        self
            .font(.title)
            .fontWeight(.bold)
            .fontDesign(.rounded)
    }
    
    /// Apply headline style with Dynamic Type
    func headlineStyle() -> some View {
        self
            .font(.title2)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
    }
    
    /// Apply body large style with Dynamic Type
    func bodyLargeStyle() -> some View {
        self
            .font(.title3)
            .fontWeight(.regular)
    }
    
    /// Apply body style with Dynamic Type
    func bodyStyle() -> some View {
        self
            .font(.body)
    }
    
    /// Apply caption style with Dynamic Type
    func captionStyle() -> some View {
        self
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Accessible Text Modifiers
extension View {
    /// Make text more readable for seniors
    func seniorReadable() -> some View {
        self
            .lineSpacing(4)
            .tracking(0.3)
    }
    
    /// Apply high contrast text style
    func highContrastText() -> some View {
        self
            .foregroundColor(.steadyTextPrimary)
            .fontWeight(.medium)
    }
}
