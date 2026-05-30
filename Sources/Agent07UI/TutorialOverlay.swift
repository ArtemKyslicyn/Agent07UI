//
//  TutorialOverlay.swift
//  Agent07UI
//
//  Tutorial overlay with step navigation and progress indicator.
//  Reusable component for contextual learning experiences.
//

import SwiftUI

// MARK: - Tutorial Step Protocol

/// Protocol defining a tutorial step
public protocol TutorialStep: Identifiable, Sendable {
    var id: String { get }
    var title: String { get }
    var description: String { get }
    var icon: String? { get }
}

// MARK: - Default Tutorial Step

/// Default implementation of a tutorial step
public struct DefaultTutorialStep: TutorialStep {
    public let id: String
    public let title: String
    public let description: String
    public let icon: String?

    public init(id: String, title: String, description: String, icon: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
    }
}

// MARK: - Tutorial Overlay

/// Overlay component that displays tutorial steps with navigation and progress tracking
public struct TutorialOverlay<Step: TutorialStep, StepContent: View>: View {
    let steps: [Step]
    let stepContent: (Step) -> StepContent
    let onComplete: () -> Void
    let onDismiss: () -> Void

    @State private var currentStepIndex: Int = 0
    @State private var isAnimating: Bool = false

    public init(
        steps: [Step],
        onComplete: @escaping () -> Void,
        onDismiss: @escaping () -> Void,
        @ViewBuilder stepContent: @escaping (Step) -> StepContent
    ) {
        self.steps = steps
        self.onComplete = onComplete
        self.onDismiss = onDismiss
        self.stepContent = stepContent
    }

    public var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss when clicking backdrop
                    onDismiss()
                }

            // Tutorial content
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator

                // Step content
                if currentStepIndex < steps.count {
                    stepView(for: steps[currentStepIndex])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }

                // Navigation buttons
                navigationButtons
            }
            .frame(minWidth: 500, maxWidth: 700, minHeight: 400, maxHeight: 600)
            .background(Theme.primary)
            .clipShape(.rect(cornerRadius: Theme.radius12))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radius12)
                    .stroke(Theme.border, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.5), radius: 20, y: 8)
        }
        .onKeyPress(.return) {
            handleNext()
            return .handled
        }
        .onKeyPress(.escape) {
            onDismiss()
            return .handled
        }
        .onKeyPress { press in
            // Handle Cmd+Left for Back
            if press.modifiers == .command && press.key == .leftArrow {
                handlePrevious()
                return .handled
            }
            return .ignored
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    // MARK: - Progress Indicator

    @ViewBuilder
    private var progressIndicator: some View {
        VStack(spacing: 8) {
            // Header with close button
            HStack {
                Text("Tutorial", comment: "Tutorial overlay: main title.")
                    .font(Theme.titleFont.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Close tutorial", comment: "Tutorial overlay: close button accessibility label."))
                .accessibilityHint(String(localized: "Dismisses the tutorial overlay", comment: "Tutorial overlay: close button accessibility hint."))
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.tertiary)
                        .frame(height: 4)

                    // Progress Fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.accent)
                        .frame(width: geometry.size.width * progressPercentage, height: 4)
                        .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 24)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "Tutorial progress: \(Int(progressPercentage * 100)) percent complete", comment: "Tutorial overlay: progress bar accessibility label."))

            // Step Counter
            HStack(spacing: 8) {
                Text("Step \(currentStepIndex + 1) of \(steps.count)", comment: "Tutorial overlay: step counter (e.g., 'Step 2 of 5').")
                    .font(Theme.captionFont.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)

                if currentStepIndex < steps.count {
                    Text("•")
                        .foregroundStyle(Theme.textSecondary.opacity(0.5))

                    Text(steps[currentStepIndex].title)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(.top, 4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(currentStepIndex < steps.count ?
                String(localized: "Step \(currentStepIndex + 1) of \(steps.count): \(steps[currentStepIndex].title)", comment: "Tutorial overlay: step counter with title accessibility (e.g., 'Step 2 of 5: Setup').") :
                String(localized: "Step \(currentStepIndex + 1) of \(steps.count)", comment: "Tutorial overlay: step counter (e.g., 'Step 2 of 5')."))
        }
        .padding(.bottom, 16)
        .background(Theme.secondary)
    }

    // MARK: - Step View

    @ViewBuilder
    private func stepView(for step: Step) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing16) {
                // Icon (if provided)
                if let icon = step.icon {
                    Image(systemName: icon)
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Theme.spacing16)
                        .accessibilityHidden(true)
                }

                // Title
                Text(step.title)
                    .font(Theme.titleFont.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityAddTraits(.isHeader)

                // Description
                Text(step.description)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)

                // Custom step content
                stepContent(step)
                    .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
    }

    // MARK: - Navigation Buttons

    @ViewBuilder
    private var navigationButtons: some View {
        HStack(spacing: Theme.spacing12) {
            // Previous button
            Button(action: handlePrevious) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Previous", comment: "Tutorial overlay: previous button.")
                        .font(Theme.bodyFont.weight(.medium))
                }
                .foregroundStyle(canGoBack ? Theme.textPrimary : Theme.textMuted)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(canGoBack ? Theme.elevated : Theme.tertiary)
                .clipShape(.rect(cornerRadius: Theme.radius8))
            }
            .buttonStyle(.plain)
            .disabled(!canGoBack)
            .accessibilityLabel(String(localized: "Previous step", comment: "Tutorial overlay: previous button accessibility label."))
            .accessibilityHint(String(localized: canGoBack ? "Go to previous tutorial step" : "No previous step available", comment: canGoBack ? "Tutorial overlay: previous button accessibility hint when enabled." : "Tutorial overlay: previous button accessibility hint when disabled."))

            Spacer()

            // Skip button
            Button(action: onDismiss) {
                Text("Skip Tutorial", comment: "Tutorial overlay: skip button.")
                    .font(Theme.bodyFont.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Skip tutorial", comment: "Tutorial overlay: skip button accessibility label."))
            .accessibilityHint(String(localized: "Exits the tutorial without completing it", comment: "Tutorial overlay: skip button accessibility hint."))

            // Next/Finish button
            Button(action: handleNext) {
                HStack(spacing: 6) {
                    Text(isLastStep ? String(localized: "Finish", comment: "Tutorial overlay: finish button on last step.") : String(localized: "Next", comment: "Tutorial overlay: next button."))
                        .font(Theme.bodyFont.weight(.medium))
                    if !isLastStep {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Theme.accent)
                .clipShape(.rect(cornerRadius: Theme.radius8))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isLastStep ? String(localized: "Finish tutorial", comment: "Tutorial overlay: finish button accessibility label.") : String(localized: "Next step", comment: "Tutorial overlay: next button accessibility label."))
            .accessibilityHint(isLastStep ? String(localized: "Completes the tutorial", comment: "Tutorial overlay: finish button accessibility hint.") : String(localized: "Go to next tutorial step", comment: "Tutorial overlay: next button accessibility hint."))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Theme.secondary)
    }

    // MARK: - Computed Properties

    private var progressPercentage: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(steps.count)
    }

    private var canGoBack: Bool {
        currentStepIndex > 0
    }

    private var isLastStep: Bool {
        currentStepIndex >= steps.count - 1
    }

    // MARK: - Navigation Handlers

    private func handleNext() {
        guard !isAnimating else { return }

        if isLastStep {
            onComplete()
        } else if currentStepIndex < steps.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAnimating = true
                currentStepIndex += 1
            }

            // Reset animation flag after transition
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                isAnimating = false
            }
        }
    }

    private func handlePrevious() {
        guard !isAnimating && canGoBack else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            isAnimating = true
            currentStepIndex -= 1
        }

        // Reset animation flag after transition
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            isAnimating = false
        }
    }
}

// MARK: - Simplified Tutorial Overlay

/// Convenience initializer for tutorials with default step content (title + description only)
extension TutorialOverlay where StepContent == EmptyView {
    public init(
        steps: [Step],
        onComplete: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.steps = steps
        self.onComplete = onComplete
        self.onDismiss = onDismiss
        self.stepContent = { _ in EmptyView() }
    }
}

// MARK: - Preview

#if DEBUG
struct TutorialOverlay_Previews: PreviewProvider {
    static var previews: some View {
        let sampleSteps = [
            DefaultTutorialStep(
                id: "1",
                title: "Welcome to Agent07",
                description: "Let's take a quick tour of the key features that will help you get the most out of your AI agent.",
                icon: "hand.wave.fill"
            ),
            DefaultTutorialStep(
                id: "2",
                title: "Contextual Learning",
                description: "Agent07 learns from your interactions and provides contextual help exactly when you need it.",
                icon: "brain.head.profile"
            ),
            DefaultTutorialStep(
                id: "3",
                title: "Interactive Documentation",
                description: "Access interactive documentation that adapts to your current workflow and skill level.",
                icon: "book.fill"
            ),
            DefaultTutorialStep(
                id: "4",
                title: "Keyboard Shortcuts",
                description: "Master keyboard shortcuts to navigate faster. Press Cmd+K to open the command palette anytime.",
                icon: "keyboard.fill"
            )
        ]

        return TutorialOverlay(
            steps: sampleSteps,
            onComplete: {},
            onDismiss: {}
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.surface)
    }
}
#endif
