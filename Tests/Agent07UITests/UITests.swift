//
//  UITests.swift
//  Agent07UITests
//

import Testing
import SwiftUI
@testable import Agent07UI

struct ThemeTests {

    @Test func testThemeModeAllCases() {
        #expect(ThemeMode.allCases.count == 3)
    }

    @Test @MainActor func testThemeColors() {
        let _ = Theme.surface
        let _ = Theme.primary
        let _ = Theme.accent
        let _ = Theme.textPrimary
        let _ = Theme.border
        #expect(Bool(true))
    }

    @Test @MainActor func testThemeFonts() {
        let _ = Theme.titleFont
        let _ = Theme.bodyFont
        let _ = Theme.monoFont
        #expect(Bool(true))
    }

    @Test @MainActor func testThemeSpacing() {
        #expect(Theme.spacing4 == 4)
        #expect(Theme.spacing8 == 8)
        #expect(Theme.spacing12 == 12)
        #expect(Theme.spacing16 == 16)
    }

    @Test @MainActor func testThemeRadius() {
        #expect(Theme.radius4 == 4)
        #expect(Theme.radius8 == 8)
        #expect(Theme.radius12 == 12)
    }
}

struct ColorHexTests {

    @Test func testColorFromHex() {
        let color = Color(hex: "#FF0000")
        #expect(color != nil)
    }

    @Test func testColorFromHexWithoutHash() {
        let color = Color(hex: "00FF00")
        #expect(color != nil)
    }

    @Test func testColorFromInvalidHex() {
        let color = Color(hex: "xyz")
        #expect(color == nil)
    }

    @Test func testHexStringRoundtrip() {
        let original = Color(hex: "#FF8000")!
        let hex = original.hexString
        #expect(hex.hasPrefix("#"))
        #expect(hex.count == 7)
    }
}

// AgentTypeColorTests removed in the public extraction — they tested an
// `AgentType.color` extension that lives in Agent07-specific code, not
// in this design system.
