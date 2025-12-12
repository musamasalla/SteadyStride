//
//  OnboardingView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color.steadyBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                if viewModel.currentStep != .welcome && viewModel.currentStep != .complete {
                    ProgressView(value: viewModel.progress)
                        .tint(.steadyPrimary)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.top, Theme.Spacing.md)
                }
                
                // Content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView(viewModel: viewModel)
                        .tag(OnboardingStep.welcome)
                    
                    NameStepView(viewModel: viewModel)
                        .tag(OnboardingStep.name)
                    
                    AgeStepView(viewModel: viewModel)
                        .tag(OnboardingStep.age)
                    
                    GoalsStepView(viewModel: viewModel)
                        .tag(OnboardingStep.goals)
                    
                    MobilityStepView(viewModel: viewModel)
                        .tag(OnboardingStep.mobility)
                    
                    ScheduleStepView(viewModel: viewModel)
                        .tag(OnboardingStep.schedule)
                    
                    HealthKitStepView(viewModel: viewModel)
                        .tag(OnboardingStep.healthKit)
                    
                    CompleteStepView(viewModel: viewModel) {
                        completeOnboarding()
                    }
                    .tag(OnboardingStep.complete)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)
            }
        }
    }
    
    private func completeOnboarding() {
        let _ = viewModel.createUser(modelContext: modelContext)
        withAnimation {
            isOnboardingComplete = true
        }
    }
}

// MARK: - Welcome Step
struct WelcomeStepView: View {
    let viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            // Logo/Icon
            Image(systemName: "figure.walk.motion")
                .font(.system(size: 100))
                .foregroundStyle(Color.steadyGradient)
            
            VStack(spacing: Theme.Spacing.md) {
                Text("Welcome to")
                    .font(Typography.headlineLarge)
                    .foregroundColor(.steadyTextSecondary)
                
                Text("SteadyStride")
                    .font(Typography.displayLarge)
                    .foregroundColor(.steadyPrimary)
                
                Text("Your personal mobility coach for a stronger, steadier you")
                    .font(Typography.bodyLarge)
                    .foregroundColor(.steadyTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
            
            Spacer()
            
            Button {
                viewModel.nextStep()
            } label: {
                Text("Get Started")
            }
            .buttonStyle(.primary)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
        }
    }
}

// MARK: - Name Step
struct NameStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            OnboardingHeader(
                title: viewModel.currentStep.title,
                subtitle: viewModel.currentStep.subtitle
            )
            
            TextField("Your name", text: $viewModel.name)
                .font(Typography.headlineLarge)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.steadyBackgroundSecondary)
                .cornerRadius(Theme.Radius.lg)
                .padding(.horizontal, Theme.Spacing.xl)
                .focused($isFocused)
            
            Spacer()
            
            OnboardingNavigation(
                viewModel: viewModel,
                canProceed: viewModel.canProceed
            )
        }
        .onAppear { isFocused = true }
    }
}

// MARK: - Age Step
struct AgeStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            OnboardingHeader(
                title: viewModel.currentStep.title,
                subtitle: viewModel.currentStep.subtitle
            )
            
            VStack(spacing: Theme.Spacing.md) {
                Text("\(viewModel.age)")
                    .font(Typography.displayLarge)
                    .foregroundColor(.steadyPrimary)
                
                Stepper("", value: $viewModel.age, in: 18...120)
                    .labelsHidden()
                
                Slider(value: Binding(
                    get: { Double(viewModel.age) },
                    set: { viewModel.age = Int($0) }
                ), in: 40...100, step: 1)
                .tint(.steadyPrimary)
                .padding(.horizontal, Theme.Spacing.xl)
            }
            
            Spacer()
            
            OnboardingNavigation(
                viewModel: viewModel,
                canProceed: viewModel.canProceed
            )
        }
    }
}

// MARK: - Goals Step
struct GoalsStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            OnboardingHeader(
                title: viewModel.currentStep.title,
                subtitle: viewModel.currentStep.subtitle
            )
            .padding(.top, Theme.Spacing.lg)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                    ForEach(HealthGoal.allCases) { goal in
                        GoalSelectionCard(
                            goal: goal,
                            isSelected: viewModel.selectedGoals.contains(goal)
                        ) {
                            toggleGoal(goal)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
            
            OnboardingNavigation(
                viewModel: viewModel,
                canProceed: viewModel.canProceed
            )
        }
    }
    
    private func toggleGoal(_ goal: HealthGoal) {
        if viewModel.selectedGoals.contains(goal) {
            viewModel.selectedGoals.remove(goal)
        } else {
            viewModel.selectedGoals.insert(goal)
        }
    }
}

struct GoalSelectionCard: View {
    let goal: HealthGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: goal.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : .steadyPrimary)
                
                Text(goal.rawValue)
                    .font(Typography.labelSmall)
                    .foregroundColor(isSelected ? .white : .steadyTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .fill(isSelected ? Color.steadyPrimary : Color.steadyCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .stroke(isSelected ? Color.clear : Color.steadyBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mobility Step
struct MobilityStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            OnboardingHeader(
                title: viewModel.currentStep.title,
                subtitle: viewModel.currentStep.subtitle
            )
            
            VStack(spacing: Theme.Spacing.md) {
                ForEach(MobilityLevel.allCases, id: \.self) { level in
                    MobilityLevelCard(
                        level: level,
                        isSelected: viewModel.selectedMobilityLevel == level
                    ) {
                        viewModel.selectedMobilityLevel = level
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            Spacer()
            
            OnboardingNavigation(
                viewModel: viewModel,
                canProceed: viewModel.canProceed
            )
        }
    }
}

struct MobilityLevelCard: View {
    let level: MobilityLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: level.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .steadyPrimary)
                    .frame(width: 44)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue)
                        .font(Typography.labelLarge)
                        .foregroundColor(isSelected ? .white : .steadyTextPrimary)
                    
                    Text(level.description)
                        .font(Typography.bodySmall)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .steadyTextSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .fill(isSelected ? Color.steadyPrimary : Color.steadyCardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Schedule Step
struct ScheduleStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            OnboardingHeader(
                title: viewModel.currentStep.title,
                subtitle: viewModel.currentStep.subtitle
            )
            
            VStack(spacing: Theme.Spacing.md) {
                ForEach(TimeOfDay.allCases, id: \.self) { time in
                    TimeOfDayCard(
                        time: time,
                        isSelected: viewModel.preferredWorkoutTime == time
                    ) {
                        viewModel.preferredWorkoutTime = time
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            Spacer()
            
            OnboardingNavigation(
                viewModel: viewModel,
                canProceed: viewModel.canProceed
            )
        }
    }
}

struct TimeOfDayCard: View {
    let time: TimeOfDay
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: time.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .steadySecondary)
                    .frame(width: 44)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(time.rawValue)
                        .font(Typography.labelLarge)
                        .foregroundColor(isSelected ? .white : .steadyTextPrimary)
                    
                    Text(time.timeRange)
                        .font(Typography.bodySmall)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .steadyTextSecondary)
                }
                
                Spacer()
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .fill(isSelected ? Color.steadyPrimary : Color.steadyCardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - HealthKit Step
struct HealthKitStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.steadyGradient)
            
            OnboardingHeader(
                title: viewModel.currentStep.title,
                subtitle: viewModel.currentStep.subtitle
            )
            
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HealthKitFeatureRow(icon: "figure.walk", text: "Track your daily steps")
                HealthKitFeatureRow(icon: "heart.fill", text: "Monitor heart rate during workouts")
                HealthKitFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Measure your progress over time")
            }
            .padding(.horizontal, Theme.Spacing.xl)
            
            Spacer()
            
            VStack(spacing: Theme.Spacing.md) {
                Button {
                    Task {
                        await viewModel.requestHealthKitPermission()
                        viewModel.nextStep()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Allow HealthKit Access")
                    }
                }
                .buttonStyle(.primary)
                .disabled(viewModel.isLoading)
                
                Button {
                    viewModel.nextStep()
                } label: {
                    Text("Skip for Now")
                }
                .buttonStyle(.tertiary)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
        }
    }
}

struct HealthKitFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.steadyPrimary)
                .frame(width: 32)
            
            Text(text)
                .font(Typography.bodyMedium)
                .foregroundColor(.steadyTextSecondary)
        }
    }
}

// MARK: - Complete Step
struct CompleteStepView: View {
    let viewModel: OnboardingViewModel
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.steadySuccess)
            
            VStack(spacing: Theme.Spacing.md) {
                Text("You're All Set!")
                    .font(Typography.displayMedium)
                    .foregroundColor(.steadyTextPrimary)
                
                Text("Welcome, \(viewModel.name)! Let's start your journey to better mobility.")
                    .font(Typography.bodyLarge)
                    .foregroundColor(.steadyTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
            
            Spacer()
            
            Button {
                onComplete()
            } label: {
                Text("Start My First Workout")
            }
            .buttonStyle(.primary)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
        }
    }
}

// MARK: - Shared Components
struct OnboardingHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Typography.displaySmall)
                .foregroundColor(.steadyTextPrimary)
            
            Text(subtitle)
                .font(Typography.bodyLarge)
                .foregroundColor(.steadyTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

struct OnboardingNavigation: View {
    let viewModel: OnboardingViewModel
    let canProceed: Bool
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            if viewModel.currentStep.rawValue > 1 {
                Button {
                    viewModel.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .buttonStyle(.secondary)
            }
            
            Button {
                viewModel.nextStep()
            } label: {
                Text("Continue")
            }
            .buttonStyle(.primary)
            .disabled(!canProceed)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.bottom, Theme.Spacing.xxl)
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
        .modelContainer(for: User.self, inMemory: true)
}
