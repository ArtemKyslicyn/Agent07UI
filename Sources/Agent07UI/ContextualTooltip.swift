//
//  ContextualTooltip.swift
//  Agent07UI
//
//  Contextual tooltip that appears when users first encounter a feature.
//  Dismissible with 'Don't show again' option for permanent dismissal.
//

import SwiftUI

// MARK: - Contextual Tooltip

/// A contextual tooltip that appears when users first encounter a feature.
/// Supports dismiss and 'don't show again' actions.
public struct ContextualTooltip: View {
    let message: String
    let icon: String?
    let arrowDirection: ArrowDirection
    var onDismiss: () -> Void
    var onDontShowAgain: (() -> Void)?

    public enum ArrowDirection {
        case up, down, leading, trailing
    }

    public init(
        message: String,
        icon: String? = "lightbulb.fill",
        arrowDirection: ArrowDirection = .up,
        onDismiss: @escaping () -> Void,
        onDontShowAgain: (() -> Void)? = nil
    ) {
        self.message = message
        self.icon = icon
        self.arrowDirection = arrowDirection
        self.onDismiss = onDismiss
        self.onDontShowAgain = onDontShowAgain
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Main content
            VStack(alignment: .leading, spacing: Theme.spacing8) {
                // Header with icon and dismiss button
                HStack(spacing: Theme.spacing8) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.info)
                            .accessibilityHidden(true)
                    }

                    Text(message)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(message)

                    Spacer()

                    // Dismiss button
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Dismiss tooltip")
                    .accessibilityHint("Closes this tooltip")
                }

                // Action buttons
                HStack(spacing: Theme.spacing8) {
                    if let onDontShowAgain {
                        Button(action: onDontShowAgain) {
                            Text("Don't show again")
                                .font(Theme.tinyFont.weight(.medium))
                                .foregroundStyle(Theme.textTertiary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Don't show again")
                        .accessibilityHint("Permanently dismisses this tooltip")
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Text("Got it")
                            .font(Theme.tinyFont.weight(.semibold))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.accent.opacity(0.15))
                            .clipShape(.rect(cornerRadius: Theme.radius4))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Got it")
                    .accessibilityHint("Closes this tooltip")
                }
            }
            .padding(Theme.spacing12)
        }
        .frame(maxWidth: 280)
        .background(Theme.elevated)
        .clipShape(.rect(cornerRadius: Theme.radius8))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius8)
                .stroke(Theme.border, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.3), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isModal)
    }
}

// MARK: - Tooltip Container

/// Container view that shows a tooltip anchored to a specific view.
public struct TooltipContainer<Content: View>: View {
    let content: Content
    let tooltip: ContextualTooltip?
    let placement: TooltipPlacement

    public enum TooltipPlacement {
        case top, bottom, leading, trailing
    }

    public init(
        tooltip: ContextualTooltip?,
        placement: TooltipPlacement = .top,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.tooltip = tooltip
        self.placement = placement
    }

    public var body: some View {
        ZStack {
            content

            if let tooltip {
                tooltipView(tooltip)
            }
        }
    }

    @ViewBuilder
    private func tooltipView(_ tooltip: ContextualTooltip) -> some View {
        switch placement {
        case .top:
            VStack(spacing: 4) {
                tooltip
                Spacer()
            }
        case .bottom:
            VStack(spacing: 4) {
                Spacer()
                tooltip
            }
        case .leading:
            HStack(spacing: 4) {
                tooltip
                Spacer()
            }
        case .trailing:
            HStack(spacing: 4) {
                Spacer()
                tooltip
            }
        }
    }
}

// MARK: - View Extension

extension View {
    /// Attach a contextual tooltip to this view
    public func contextualTooltip(
        _ tooltip: ContextualTooltip?,
        placement: TooltipContainer<AnyView>.TooltipPlacement = .top
    ) -> some View {
        TooltipContainer(tooltip: tooltip, placement: placement) {
            AnyView(self)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ContextualTooltip_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            // Basic tooltip
            ContextualTooltip(
                message: "This is the command palette. Press Cmd+K to open it anytime.",
                onDismiss: {},
                onDontShowAgain: {}
            )

            // Tooltip without icon
            ContextualTooltip(
                message: "You can customize your workspace layout by dragging panels.",
                icon: nil,
                onDismiss: {}
            )

            // Tooltip with custom icon
            ContextualTooltip(
                message: "Pro tip: Use Cmd+/ to toggle the terminal quickly.",
                icon: "terminal.fill",
                onDismiss: {},
                onDontShowAgain: {}
            )

            // Long message tooltip
            ContextualTooltip(
                message: "The pipeline editor allows you to chain multiple AI agents together. Create complex workflows by connecting agents with different capabilities.",
                icon: "link.circle.fill",
                onDismiss: {},
                onDontShowAgain: {}
            )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.surface)
    }
}
#endif
