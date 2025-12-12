//
//  Theme.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

/// Main theme configuration for SteadyStride
/// Designed with senior users in mind - high contrast, large touch targets, and accessibility-first
struct Theme {
    
    // MARK: - Spacing
    struct Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999
    }
    
    // Alias for convenience
    typealias CornerRadius = Radius
    
    // Convenience accessors
    struct CornerRadiusValues {
        static let small: CGFloat = Radius.sm
        static let medium: CGFloat = Radius.md
        static let large: CGFloat = Radius.lg
        static let full: CGFloat = Radius.full
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let sm = ShadowStyle(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        static let md = ShadowStyle(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        static let lg = ShadowStyle(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Touch Targets
    struct TouchTarget {
        /// Minimum touch target size for accessibility (44pt as per Apple HIG)
        static let minimum: CGFloat = 44
        /// Larger touch target for primary actions
        static let comfortable: CGFloat = 56
        /// Extra large for critical actions
        static let large: CGFloat = 64
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
    }
    
    // MARK: - Icon Sizes
    struct IconSize {
        static let sm: CGFloat = 16
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
        static let xl: CGFloat = 48
        static let xxl: CGFloat = 64
    }
}

// MARK: - Shadow Style Helper
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extension for Shadows
extension View {
    func shadowStyle(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
