//
//  View+Extensions.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

// MARK: - Card Styling
extension View {
    /// Apply standard card styling
    func cardStyle(padding: CGFloat = Theme.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .fill(Color.steadyCardBackground)
            )
            .shadowStyle(Theme.Shadow.md)
    }
    
    /// Apply subtle card styling without shadow
    func subtleCardStyle(padding: CGFloat = Theme.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .fill(Color.steadyBackgroundSecondary)
            )
    }
}

// MARK: - Accessibility Helpers
extension View {
    /// Make the view accessible with a label
    func accessibleTapTarget(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Add minimum tap area for accessibility
    func seniorFriendlyTapTarget() -> some View {
        self
            .frame(minWidth: Theme.TouchTarget.minimum, minHeight: Theme.TouchTarget.minimum)
            .contentShape(Rectangle())
    }
}

// MARK: - Conditional Modifiers
extension View {
    /// Apply modifier conditionally
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Apply different modifiers based on condition
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
}

// MARK: - Shimmer Loading Effect
extension View {
    /// Add shimmer loading effect
    func shimmer(isActive: Bool = true) -> some View {
        self
            .redacted(reason: isActive ? .placeholder : [])
            .shimmering(active: isActive)
    }
}

struct ShimmerModifier: ViewModifier {
    var active: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if active {
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.5),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                        .animation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                            value: phase
                        )
                    }
                }
                .mask(content)
            )
            .onAppear {
                if active {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmering(active: Bool = true) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}

// MARK: - Haptic Feedback
extension View {
    /// Trigger haptic feedback on tap
    func hapticOnTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
            }
        )
    }
    
    /// Trigger success haptic
    func hapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Navigation Helpers
extension View {
    /// Hide navigation bar back button text
    func hideBackButtonText() -> some View {
        self.navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EmptyView()
                }
            }
    }
}

// MARK: - Keyboard Helpers
extension View {
    /// Hide keyboard on tap
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Gradient Overlays
extension View {
    /// Apply a gradient overlay from bottom
    func gradientOverlay(colors: [Color] = [.clear, .black.opacity(0.6)]) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Debug Helpers
#if DEBUG
extension View {
    /// Add debug border
    func debugBorder(_ color: Color = .red) -> some View {
        self.border(color, width: 1)
    }
}
#endif
