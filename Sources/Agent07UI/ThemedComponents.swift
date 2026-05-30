//
//  ThemedComponents.swift
//  Agent07UI
//
//  Reusable themed SwiftUI components.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

// MARK: - Color Helpers

extension Color {
    public init(w: CGFloat) {
        #if canImport(AppKit)
        self.init(nsColor: NSColor(white: w, alpha: 1))
        #elseif canImport(UIKit)
        self.init(uiColor: UIColor(white: w, alpha: 1))
        #else
        self.init(white: Double(w))
        #endif
    }

    public init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6, let rgb = UInt64(h, radix: 16) else { return nil }
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }

    public var hexString: String {
        #if canImport(AppKit)
        let c = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        return String(format: "#%02X%02X%02X",
                      Int(c.redComponent * 255),
                      Int(c.greenComponent * 255),
                      Int(c.blueComponent * 255))
        #elseif canImport(UIKit)
        let color = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return String(format: "#%02X%02X%02X",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255))
        #else
        return "#000000"
        #endif
    }
}

// MARK: - Themed Card

public struct ThemedCard<Content: View>: View {
    let content: Content
    var isSelected: Bool = false
    var isHovered: Bool = false

    public init(isSelected: Bool = false, isHovered: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isSelected = isSelected
        self.isHovered = isHovered
    }

    public var body: some View {
        content
            .padding(Theme.spacing12)
            .background(isHovered ? Theme.hover : isSelected ? Theme.elevated : Theme.tertiary)
            .clipShape(.rect(cornerRadius: Theme.radius8))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.radius8)
                    .stroke(isSelected ? Theme.borderActive : Theme.border, lineWidth: isSelected ? 1.5 : 0.5)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Themed Section Label

public struct ThemedSectionLabel: View {
    let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(Theme.tinyFont.weight(.semibold))
            .foregroundStyle(Theme.textSecondary)
            .textCase(.uppercase)
    }
}

// MARK: - Themed Button

public struct ThemedButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var tint: Color = Theme.accent

    public init(_ title: String, icon: String? = nil, tint: Color = Theme.accent, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon { Image(systemName: icon).font(Theme.tinyFont) }
                Text(title).font(Theme.captionFont.weight(.medium))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.15))
            .foregroundStyle(tint)
            .clipShape(.rect(cornerRadius: Theme.radius4))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint("Activates \(title)")
    }

    private var accessibilityLabelText: String {
        if let icon {
            return "\(title) button with \(icon) icon"
        } else {
            return "\(title) button"
        }
    }
}

// MARK: - Themed Empty State

public struct ThemedEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: (() -> Void)?
    var actionTitle: String = ""

    public init(icon: String, title: String, subtitle: String,
                action: (() -> Void)? = nil, actionTitle: String = "") {
        self.icon = icon; self.title = title; self.subtitle = subtitle
        self.action = action; self.actionTitle = actionTitle
    }

    public var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon)
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(Theme.textMuted)
                .accessibilityHidden(true)
            Text(title)
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
            Text(subtitle)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textTertiary)
                .multilineTextAlignment(.center)
            if let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                    .font(Theme.captionFont)
                    .accessibilityLabel(actionTitle)
                    .accessibilityHint("Activates \(actionTitle)")
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint(action != nil ? "Contains action button: \(actionTitle)" : "")
    }

    private var accessibilityLabelText: String {
        var label = "Empty state: \(title). \(subtitle)"
        if action != nil {
            label += ". Action available: \(actionTitle)"
        }
        return label
    }
}

// MARK: - Status Badge

public struct StatusBadge: View {
    let status: ExecutionStatus
    let duration: TimeInterval?

    public init(status: ExecutionStatus, duration: TimeInterval? = nil) {
        self.status = status; self.duration = duration
    }

    public var body: some View {
        HStack(spacing: 4) {
            switch status {
            case .idle:
                EmptyView()
            case .running:
                ProgressView().scaleEffect(0.4)
                Text("Running").font(Theme.tinyFont).foregroundStyle(Theme.warning)
            case .success:
                Circle().fill(Theme.success).frame(width: 6, height: 6)
                Text("Done").font(Theme.tinyFont).foregroundStyle(Theme.success)
                if let d = duration {
                    Text("(\(String(format: "%.1fs", d)))").font(Theme.tinyFont).foregroundStyle(Theme.textTertiary)
                }
            case .error:
                Circle().fill(Theme.error).frame(width: 6, height: 6)
                Text("Error").font(Theme.tinyFont).foregroundStyle(Theme.error)
            }
        }
    }
}

// MARK: - Linear Progress Bar
//
// Shape-based replacement for `ProgressView(value:)` linear style.
// Avoids the macOS `NSProgressIndicator` host's fractional-width constraint
// warning ("maximum length doesn't satisfy min <= max").
public struct LinearProgressBar: View {
    let value: Double
    let tint: Color
    let trackOpacity: Double
    let height: CGFloat

    public init(value: Double, tint: Color, trackOpacity: Double = 0.15, height: CGFloat = 4) {
        self.value = value
        self.tint = tint
        self.trackOpacity = trackOpacity
        self.height = height
    }

    public var body: some View {
        let clamped = max(0, min(1, value))
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(tint.opacity(trackOpacity))
                Capsule()
                    .fill(tint)
                    .frame(width: geo.size.width * clamped)
            }
        }
        .frame(height: height)
    }
}
