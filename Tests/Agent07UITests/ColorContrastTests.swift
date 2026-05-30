//
//  ColorContrastTests.swift
//  Agent07UITests
//
//  WCAG 2.1 AA Color Contrast Verification
//  Tests all theme colors for accessibility compliance in both dark and light modes.
//

import Testing
import SwiftUI
@testable import Agent07UI

// MARK: - Dark Theme Contrast Tests

struct DarkThemeContrastTests {

    // MARK: - Setup

    @MainActor
    private func setupDarkMode() {
        Theme.mode = .dark
    }

    // MARK: - Text on Surface Backgrounds

    @Test @MainActor func testPrimaryTextOnSurface() {
        setupDarkMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.surface))
    }

    @Test @MainActor func testPrimaryTextOnPrimary() {
        setupDarkMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.primary))
    }

    @Test @MainActor func testPrimaryTextOnSecondary() {
        setupDarkMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.secondary))
    }

    @Test @MainActor func testPrimaryTextOnTertiary() {
        setupDarkMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.tertiary))
    }

    @Test @MainActor func testPrimaryTextOnElevated() {
        setupDarkMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.elevated))
    }

    @Test @MainActor func testPrimaryTextOnHover() {
        setupDarkMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.hover))
    }

    @Test @MainActor func testSecondaryTextOnSurface() {
        setupDarkMode()
        #expect(Theme.meetsAAText(foreground: Theme.textSecondary, background: Theme.surface))
    }

    @Test @MainActor func testSecondaryTextOnPrimary() {
        setupDarkMode()
        #expect(Theme.meetsAAText(foreground: Theme.textSecondary, background: Theme.primary))
    }

    // MARK: - Accent Colors

    @Test @MainActor func testAccentOnSurface() {
        setupDarkMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.accent, background: Theme.surface))
    }

    @Test @MainActor func testAccentOnPrimary() {
        setupDarkMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.accent, background: Theme.primary))
    }

    // MARK: - Semantic Colors

    @Test @MainActor func testSuccessColorContrast() {
        setupDarkMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.success, background: Theme.surface))
    }

    @Test @MainActor func testWarningColorContrast() {
        setupDarkMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.warning, background: Theme.surface))
    }

    @Test @MainActor func testErrorColorContrast() {
        setupDarkMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.error, background: Theme.surface))
    }

    @Test @MainActor func testInfoColorContrast() {
        setupDarkMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.info, background: Theme.surface))
    }

    // MARK: - Contrast Ratio Calculations

    @Test @MainActor func testContrastRatioCalculation() {
        setupDarkMode()
        let ratio = Theme.contrastRatio(between: Theme.textPrimary, and: Theme.surface)
        #expect(ratio != nil)
        #expect(ratio! >= 4.5)
    }

    @Test @MainActor func testRelativeLuminanceCalculation() {
        setupDarkMode()
        let luminance = Theme.relativeLuminance(of: Theme.textPrimary)
        #expect(luminance != nil)
        #expect(luminance! >= 0.0)
        #expect(luminance! <= 1.0)
    }

    @Test @MainActor func testRGBComponentsExtraction() {
        setupDarkMode()
        let components = Theme.rgbComponents(from: Theme.textPrimary)
        #expect(components != nil)
        #expect(components!.red >= 0.0 && components!.red <= 1.0)
        #expect(components!.green >= 0.0 && components!.green <= 1.0)
        #expect(components!.blue >= 0.0 && components!.blue <= 1.0)
    }
}

// MARK: - Light Theme Contrast Tests

struct LightThemeContrastTests {

    // MARK: - Setup

    @MainActor
    private func setupLightMode() {
        Theme.mode = .light
    }

    // MARK: - Text on Surface Backgrounds

    @Test @MainActor func testPrimaryTextOnSurface() {
        setupLightMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.surface))
    }

    @Test @MainActor func testPrimaryTextOnPrimary() {
        setupLightMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.primary))
    }

    @Test @MainActor func testPrimaryTextOnSecondary() {
        setupLightMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.secondary))
    }

    @Test @MainActor func testPrimaryTextOnTertiary() {
        setupLightMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.tertiary))
    }

    @Test @MainActor func testPrimaryTextOnElevated() {
        setupLightMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.elevated))
    }

    @Test @MainActor func testPrimaryTextOnHover() {
        setupLightMode()
        #expect(Theme.meetsAAText(foreground: Theme.textPrimary, background: Theme.hover))
    }

    @Test @MainActor func testSecondaryTextOnSurface() {
        setupLightMode()
        #expect(Theme.meetsAAText(foreground: Theme.textSecondary, background: Theme.surface))
    }

    @Test @MainActor func testSecondaryTextOnPrimary() {
        setupLightMode()
        #expect(Theme.meetsAAText(foreground: Theme.textSecondary, background: Theme.primary))
    }

    // MARK: - Accent Colors

    @Test @MainActor func testAccentOnSurface() {
        setupLightMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.accent, background: Theme.surface))
    }

    @Test @MainActor func testAccentOnPrimary() {
        setupLightMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.accent, background: Theme.primary))
    }

    // MARK: - Semantic Colors

    @Test @MainActor func testSuccessColorContrast() {
        setupLightMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.success, background: Theme.surface))
    }

    @Test @MainActor func testWarningColorContrast() {
        setupLightMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.warning, background: Theme.surface))
    }

    @Test @MainActor func testErrorColorContrast() {
        setupLightMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.error, background: Theme.surface))
    }

    @Test @MainActor func testInfoColorContrast() {
        setupLightMode()
        #expect(Theme.meetsAAGraphics(foreground: Theme.info, background: Theme.surface))
    }

    // MARK: - Contrast Ratio Calculations

    @Test @MainActor func testContrastRatioCalculation() {
        setupLightMode()
        let ratio = Theme.contrastRatio(between: Theme.textPrimary, and: Theme.surface)
        #expect(ratio != nil)
        #expect(ratio! >= 4.5)
    }

    @Test @MainActor func testRelativeLuminanceCalculation() {
        setupLightMode()
        let luminance = Theme.relativeLuminance(of: Theme.textPrimary)
        #expect(luminance != nil)
        #expect(luminance! >= 0.0)
        #expect(luminance! <= 1.0)
    }

    @Test @MainActor func testRGBComponentsExtraction() {
        setupLightMode()
        let components = Theme.rgbComponents(from: Theme.textPrimary)
        #expect(components != nil)
        #expect(components!.red >= 0.0 && components!.red <= 1.0)
        #expect(components!.green >= 0.0 && components!.green <= 1.0)
        #expect(components!.blue >= 0.0 && components!.blue <= 1.0)
    }
}

// MARK: - Cross-Theme Consistency Tests

struct ThemeConsistencyTests {

    @Test @MainActor func testDarkModeDetection() {
        Theme.mode = .dark
        #expect(Theme.isDark == true)
    }

    @Test @MainActor func testLightModeDetection() {
        Theme.mode = .light
        #expect(Theme.isDark == false)
    }

    @Test @MainActor func testLargeTextContrastThreshold() {
        Theme.mode = .dark
        // Large text requires 3:1 ratio (lower than normal text 4.5:1)
        #expect(Theme.meetsAALargeText(foreground: Theme.textPrimary, background: Theme.surface))
    }

    @Test @MainActor func testBorderVisibility() {
        // Border should be visible (have some contrast) but not necessarily meet text standards
        Theme.mode = .dark
        let darkRatio = Theme.contrastRatio(between: Theme.border, and: Theme.surface)
        #expect(darkRatio != nil)
        #expect(darkRatio! >= 1.0)

        Theme.mode = .light
        let lightRatio = Theme.contrastRatio(between: Theme.border, and: Theme.surface)
        #expect(lightRatio != nil)
        #expect(lightRatio! >= 1.0)
    }

    @Test @MainActor func testActiveBorderContrast() {
        Theme.mode = .dark
        #expect(Theme.meetsAAGraphics(foreground: Theme.borderActive, background: Theme.surface))

        Theme.mode = .light
        #expect(Theme.meetsAAGraphics(foreground: Theme.borderActive, background: Theme.surface))
    }
}

// MARK: - Edge Case Tests

struct ContrastEdgeCaseTests {

    @Test @MainActor func testSameColorContrast() {
        // Same color should have 1:1 contrast ratio
        let ratio = Theme.contrastRatio(between: .white, and: .white)
        #expect(ratio != nil)
        #expect(ratio! >= 1.0 && ratio! <= 1.1)
    }

    @Test @MainActor func testMaximumContrast() {
        // Black on white should have maximum contrast (~21:1)
        let ratio = Theme.contrastRatio(between: .black, and: .white)
        #expect(ratio != nil)
        #expect(ratio! >= 20.0)
    }

    @Test @MainActor func testMutedTextReadability() {
        Theme.mode = .dark
        // Muted text may not meet AA standards but should still be somewhat readable
        let ratio = Theme.contrastRatio(between: Theme.textMuted, and: Theme.surface)
        #expect(ratio != nil)
        #expect(ratio! >= 2.0)
    }
}
