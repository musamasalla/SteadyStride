//
//  ButtonStyles.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

// MARK: - Primary Button Style
/// Large, accessible primary button for main actions
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.labelLarge)
            .foregroundColor(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: Theme.TouchTarget.comfortable)
            .padding(.horizontal, Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .fill(isEnabled ? Color.steadyPrimary : Color.steadyDisabled)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
/// Outlined secondary button for alternative actions
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.labelLarge)
            .foregroundColor(isEnabled ? .steadyPrimary : .steadyDisabled)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.TouchTarget.comfortable)
            .padding(.horizontal, Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .stroke(isEnabled ? Color.steadyPrimary : Color.steadyDisabled, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Tertiary Button Style
/// Text-only button for less prominent actions
struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.labelMedium)
            .foregroundColor(.steadyPrimary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Large Icon Button Style
/// Circular button with icon - for workout controls
struct LargeIconButtonStyle: ButtonStyle {
    var backgroundColor: Color = .steadyPrimary
    var size: CGFloat = Theme.TouchTarget.large
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 28, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .shadowStyle(Theme.Shadow.md)
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(Theme.Animation.spring, value: configuration.isPressed)
    }
}

// MARK: - Card Button Style
/// Tappable card for exercises and routines
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .fill(Color.steadyCardBackground)
                    .shadowStyle(configuration.isPressed ? Theme.Shadow.sm : Theme.Shadow.md)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Chip Button Style
/// Small pill-shaped button for filters and categories
struct ChipButtonStyle: ButtonStyle {
    var isSelected: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.labelSmall)
            .foregroundColor(isSelected ? .white : .steadyTextSecondary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? Color.steadyPrimary : Color.steadyBackgroundSecondary)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Emergency Stop Button Style
/// High-visibility stop button for workout emergencies
struct EmergencyStopButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.labelLarge)
            .foregroundColor(.white)
            .frame(width: 80, height: 80)
            .background(
                Circle()
                    .fill(Color.steadyError)
                    .shadowStyle(Theme.Shadow.lg)
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(Theme.Animation.spring, value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static func primary(fullWidth: Bool) -> PrimaryButtonStyle {
        PrimaryButtonStyle(isFullWidth: fullWidth)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == TertiaryButtonStyle {
    static var tertiary: TertiaryButtonStyle { TertiaryButtonStyle() }
}

extension ButtonStyle where Self == CardButtonStyle {
    static var card: CardButtonStyle { CardButtonStyle() }
}
