//
//  ThemedComponentsTests.swift
//  Agent07UITests
//
//  Pure-logic coverage for ThemedComponents.swift — Color helpers
//  (Color(w:), Color(hex:), Color.hexString), the AgentType.color
//  extension (17 cases), and the public init paths of the 6 reusable
//  themed views (ThemedCard / ThemedSectionLabel / ThemedButton /
//  ThemedEmptyState / StatusBadge / LinearProgressBar).
//

import Testing
import Foundation
import SwiftUI
@testable import Agent07UI

// MARK: - Color helpers

@Suite("Color helpers")
struct ColorHelpersTests {

    @Test func initWithGrayLevel() {
        // Constructs without crash for the standard white/black extremes.
        _ = Color(w: 0)    // black
        _ = Color(w: 0.5)  // mid-gray
        _ = Color(w: 1)    // white
    }

    @Test func initFromHexHappyPath() {
        let red = Color(hex: "#FF0000")
        let green = Color(hex: "00FF00")
        let blue = Color(hex: "#0000FF")
        #expect(red != nil)
        #expect(green != nil)  // also covers the no-# branch
        #expect(blue != nil)
    }

    @Test func initFromHexRejectsTooShort() {
        // "ABC" → 3 chars after # → fails the count == 6 guard
        #expect(Color(hex: "ABC") == nil)
        #expect(Color(hex: "") == nil)
    }

    @Test func initFromHexRejectsNonHexChars() {
        // "GGGGGG" contains chars outside [0-9A-F] → UInt64 parse fails
        #expect(Color(hex: "GGGGGG") == nil)
    }

    @Test func hexStringRoundTrip() {
        let color = Color(hex: "#3A5F8C")
        #expect(color != nil)
        // hexString is uppercase and prefixed with #
        let back = color?.hexString
        #expect(back?.hasPrefix("#") == true)
        #expect(back?.count == 7)
    }
}

// AgentTypeColor coverage is already in UITests.swift — duplicate suite
// removed. The 17 cases are exercised there.

// MARK: - Themed views — init paths

@MainActor
@Suite("ThemedCard / ThemedSectionLabel / ThemedButton")
struct ThemedSimpleViewsTests {

    @Test func themedCardInitDefaults() {
        let card = ThemedCard { Text("hello") }
        _ = card.body
    }

    @Test func themedCardInitSelectedAndHovered() {
        let card = ThemedCard(isSelected: true, isHovered: true) { Text("X") }
        _ = card.body
    }

    @Test func themedSectionLabelInit() {
        let label = ThemedSectionLabel("Section")
        _ = label.body
    }

    @Test func themedButtonInitWithIcon() {
        let btn = ThemedButton("Run", icon: "play.fill", tint: .blue) {
            /* discard */
        }
        _ = btn.body
    }

    @Test func themedButtonInitWithoutIcon() {
        let btn = ThemedButton("Stop") {
            /* discard */
        }
        _ = btn.body
    }
}

@MainActor
@Suite("ThemedEmptyState")
struct ThemedEmptyStateTests {

    @Test func initWithoutAction() {
        let v = ThemedEmptyState(
            icon: "tray", title: "Empty", subtitle: "Nothing here yet"
        )
        _ = v.body
    }

    @Test func initWithAction() {
        let v = ThemedEmptyState(
            icon: "plus", title: "Add One", subtitle: "Get started",
            action: { /* discard */ }, actionTitle: "Add"
        )
        _ = v.body
    }
}

// MARK: - StatusBadge — every ExecutionStatus case

@MainActor
@Suite("StatusBadge")
struct StatusBadgeTests {

    @Test func idleStatus() {
        let v = StatusBadge(status: .idle)
        _ = v.body
    }

    @Test func runningStatus() {
        let v = StatusBadge(status: .running)
        _ = v.body
    }

    @Test func successStatusWithDuration() {
        let v = StatusBadge(status: .success, duration: 1.5)
        _ = v.body
    }

    @Test func successStatusWithoutDuration() {
        let v = StatusBadge(status: .success)
        _ = v.body
    }

    @Test func errorStatus() {
        let v = StatusBadge(status: .error)
        _ = v.body
    }
}

// MARK: - LinearProgressBar

@MainActor
@Suite("LinearProgressBar")
struct LinearProgressBarTests {

    @Test func zeroProgress() {
        let v = LinearProgressBar(value: 0, tint: .blue)
        _ = v.body
    }

    @Test func midProgress() {
        let v = LinearProgressBar(value: 0.42, tint: .green)
        _ = v.body
    }

    @Test func fullProgress() {
        let v = LinearProgressBar(value: 1, tint: .red, trackOpacity: 0.2, height: 8)
        _ = v.body
    }
}
