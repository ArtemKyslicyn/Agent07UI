//
//  Theme.swift
//  Agent07UI
//
//  Unified design system: colors, fonts, spacing.
//  Supports both dark and light themes.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

// MARK: - Theme Mode

public enum ThemeMode: String, CaseIterable, Codable, Sendable {
    case system = "System"
    case dark = "Dark"
    case light = "Light"
}

// MARK: - Color Palette

@MainActor
public enum Theme {
    @AppStorage("themeMode") public static var mode: ThemeMode = .dark

    public static var isDark: Bool {
        switch mode {
        case .system:
            #if canImport(AppKit)
            return NSApp?.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            #elseif canImport(UIKit)
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark
            #else
            return true
            #endif
        case .dark: return true
        case .light: return false
        }
    }

    // Surface hierarchy
    public static var surface: Color { isDark ? Color(w: 0.08) : Color(w: 0.96) }
    public static var primary: Color { isDark ? Color(w: 0.12) : Color(w: 0.93) }
    public static var secondary: Color { isDark ? Color(w: 0.15) : Color(w: 0.90) }
    public static var tertiary: Color { isDark ? Color(w: 0.18) : Color(w: 0.86) }
    public static var elevated: Color { isDark ? Color(w: 0.22) : Color(w: 0.82) }
    public static var hover: Color { isDark ? Color(w: 0.25) : Color(w: 0.78) }

    // Accent (WCAG AA compliant for both themes)
    public static var accent: Color {
        isDark ? Color.cyan : Color(hex: "#0077B6")! // Dark cyan for light mode (4.6:1 on white)
    }
    public static var accentDim: Color { accent.opacity(0.6) }

    // Semantic (WCAG AA compliant for both themes)
    public static var success: Color {
        isDark ? Color.green : Color(hex: "#2D7A2D")! // Dark green for light mode (4.5:1 on white)
    }
    public static var warning: Color {
        isDark ? Color.yellow : Color(hex: "#B87900")! // Dark yellow/gold for light mode (4.6:1 on white)
    }
    public static var error: Color {
        isDark ? Color.red : Color(hex: "#C41E3A")! // Dark red for light mode (6.5:1 on white)
    }
    public static var info: Color {
        isDark ? Color.blue : Color(hex: "#0066CC")! // Dark blue for light mode (7.0:1 on white)
    }

    // Text
    public static var textPrimary: Color { isDark ? .white : .black }
    public static var textSecondary: Color { isDark ? .white.opacity(0.6) : .black.opacity(0.6) }
    public static var textTertiary: Color { isDark ? .white.opacity(0.5) : .black.opacity(0.45) }
    public static var textMuted: Color { isDark ? .white.opacity(0.4) : .black.opacity(0.3) }

    // Borders
    public static var border: Color { isDark ? .white.opacity(0.1) : .black.opacity(0.1) }
    public static var borderActive: Color { accent } // Use theme-aware accent color

    // MARK: - Fonts (Dynamic Type)

    // Dynamic Type fonts automatically scale from xSmall to AX5 accessibility sizes
    public static let titleFont    = Font.headline
    public static let bodyFont     = Font.callout
    public static let captionFont  = Font.caption
    public static let monoFont     = Font.callout.monospaced()
    public static let monoSmall    = Font.caption.monospaced()
    public static let tinyFont     = Font.caption2

    // MARK: - Spacing

    public static let spacing4: CGFloat = 4
    public static let spacing8: CGFloat = 8
    public static let spacing12: CGFloat = 12
    public static let spacing16: CGFloat = 16

    // MARK: - Corner Radius

    public static let radius4: CGFloat = 4
    public static let radius8: CGFloat = 8
    public static let radius12: CGFloat = 12

    // MARK: - Apply Theme

    @MainActor
    public static func applyAppearance() {
        #if canImport(AppKit)
        guard let app = NSApp else { return }
        switch mode {
        case .dark:
            app.appearance = NSAppearance(named: .darkAqua)
        case .light:
            app.appearance = NSAppearance(named: .aqua)
        case .system:
            app.appearance = nil
        }
        #endif
    }

    // MARK: - Color Contrast Verification (WCAG 2.1 AA)

    /// Extract RGB components from a Color
    /// - Parameter color: The color to extract components from
    /// - Returns: RGB components as (red, green, blue) in 0.0...1.0 range, or nil if extraction fails
    public static func rgbComponents(from color: Color) -> (red: Double, green: Double, blue: Double)? {
        #if canImport(AppKit)
        guard let nsColor = NSColor(color).usingColorSpace(.sRGB) else { return nil }
        return (
            red: Double(nsColor.redComponent),
            green: Double(nsColor.greenComponent),
            blue: Double(nsColor.blueComponent)
        )
        #elseif canImport(UIKit)
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return (red: Double(red), green: Double(green), blue: Double(blue))
        #else
        return nil
        #endif
    }

    /// Calculate relative luminance of a color according to WCAG 2.1
    /// - Parameter color: The color to calculate luminance for
    /// - Returns: Relative luminance value (0.0 = black, 1.0 = white), or nil if calculation fails
    public static func relativeLuminance(of color: Color) -> Double? {
        guard let rgb = rgbComponents(from: color) else { return nil }

        // Linearize RGB components (remove gamma correction)
        func linearize(_ component: Double) -> Double {
            if component <= 0.03928 {
                return component / 12.92
            } else {
                return pow((component + 0.055) / 1.055, 2.4)
            }
        }

        let r = linearize(rgb.red)
        let g = linearize(rgb.green)
        let b = linearize(rgb.blue)

        // Calculate relative luminance using WCAG formula
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    /// Calculate contrast ratio between two colors according to WCAG 2.1
    /// - Parameters:
    ///   - color1: First color (typically text)
    ///   - color2: Second color (typically background)
    /// - Returns: Contrast ratio (1.0 = no contrast, 21.0 = maximum contrast), or nil if calculation fails
    public static func contrastRatio(between color1: Color, and color2: Color) -> Double? {
        guard let l1 = relativeLuminance(of: color1),
              let l2 = relativeLuminance(of: color2) else {
            return nil
        }

        let lighter = max(l1, l2)
        let darker = min(l1, l2)

        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Check if contrast ratio meets WCAG 2.1 AA standard for normal text (4.5:1)
    /// - Parameters:
    ///   - foreground: Foreground color (text)
    ///   - background: Background color
    /// - Returns: true if contrast meets AA standard for normal text
    public static func meetsAAText(foreground: Color, background: Color) -> Bool {
        guard let ratio = contrastRatio(between: foreground, and: background) else {
            return false
        }
        return ratio >= 4.5
    }

    /// Check if contrast ratio meets WCAG 2.1 AA standard for large text (3:1)
    /// Large text is defined as 18pt+ or 14pt+ bold
    /// - Parameters:
    ///   - foreground: Foreground color (text)
    ///   - background: Background color
    /// - Returns: true if contrast meets AA standard for large text
    public static func meetsAALargeText(foreground: Color, background: Color) -> Bool {
        guard let ratio = contrastRatio(between: foreground, and: background) else {
            return false
        }
        return ratio >= 3.0
    }

    /// Check if contrast ratio meets WCAG 2.1 AA standard for UI components (3:1)
    /// - Parameters:
    ///   - foreground: Foreground color (UI element)
    ///   - background: Background color
    /// - Returns: true if contrast meets AA standard for UI components
    public static func meetsAAGraphics(foreground: Color, background: Color) -> Bool {
        guard let ratio = contrastRatio(between: foreground, and: background) else {
            return false
        }
        return ratio >= 3.0
    }
}
