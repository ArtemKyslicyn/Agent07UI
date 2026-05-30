//
//  TutorialOverlayAndTooltipTests.swift
//  Agent07UITests
//
//  Init-path + nested-enum coverage for TutorialOverlay and
//  ContextualTooltip / TooltipContainer.
//

import Testing
import Foundation
import SwiftUI
@testable import Agent07UI

// MARK: - DefaultTutorialStep

@Suite("DefaultTutorialStep")
struct DefaultTutorialStepTests {

    @Test func initWithIcon() {
        let step = DefaultTutorialStep(id: "1", title: "Welcome",
                                        description: "Take a tour",
                                        icon: "hand.wave.fill")
        #expect(step.id == "1")
        #expect(step.title == "Welcome")
        #expect(step.description == "Take a tour")
        #expect(step.icon == "hand.wave.fill")
    }

    @Test func initWithoutIconDefaultsToNil() {
        let step = DefaultTutorialStep(id: "1", title: "T", description: "D")
        #expect(step.icon == nil)
    }

    @Test func twoStepsHaveDistinctIDs() {
        let a = DefaultTutorialStep(id: "a", title: "A", description: "")
        let b = DefaultTutorialStep(id: "b", title: "B", description: "")
        #expect(a.id != b.id)
    }
}

// MARK: - TutorialOverlay

@MainActor
@Suite("TutorialOverlay")
struct TutorialOverlayTests {

    @Test func initWithSteps() {
        let steps = [
            DefaultTutorialStep(id: "1", title: "Step 1", description: "First"),
            DefaultTutorialStep(id: "2", title: "Step 2", description: "Second")
        ]
        var completed = false
        var dismissed = false
        let overlay = TutorialOverlay(
            steps: steps,
            onComplete: { completed = true },
            onDismiss: { dismissed = true },
            stepContent: { step in Text(step.title) }
        )
        _ = overlay.body
        // Closures aren't invoked from the init/body lift alone; we just
        // verify construction without crash.
        _ = completed; _ = dismissed
    }

    @Test func initWithEmptyStepsArray() {
        let overlay = TutorialOverlay<DefaultTutorialStep, Text>(
            steps: [],
            onComplete: {},
            onDismiss: {},
            stepContent: { step in Text(step.title) }
        )
        _ = overlay.body
    }
}

// MARK: - ContextualTooltip

@MainActor
@Suite("ContextualTooltip")
struct ContextualTooltipTests {

    @Test func initWithDefaults() {
        let t = ContextualTooltip(message: "Try this!", onDismiss: {})
        _ = t.body
    }

    @Test func initWithoutIcon() {
        let t = ContextualTooltip(message: "msg", icon: nil, onDismiss: {})
        _ = t.body
    }

    @Test func initWithDontShowAgainCallback() {
        let t = ContextualTooltip(
            message: "msg",
            icon: "lightbulb.fill",
            arrowDirection: .down,
            onDismiss: {},
            onDontShowAgain: {}
        )
        _ = t.body
    }

    @Test func arrowDirectionAllCasesExist() {
        // Touches every enum case to lock the API surface.
        let cases: [ContextualTooltip.ArrowDirection] = [
            .up, .down, .leading, .trailing
        ]
        #expect(cases.count == 4)
    }
}

// MARK: - TooltipContainer

@MainActor
@Suite("TooltipContainer")
struct TooltipContainerTests {

    @Test func initWithoutTooltip() {
        let c = TooltipContainer<Text>(tooltip: nil, placement: .top) {
            Text("content")
        }
        _ = c.body
    }

    @Test func initWithTooltipAllPlacements() {
        let tooltip = ContextualTooltip(message: "msg", onDismiss: {})
        for placement in [TooltipContainer<Text>.TooltipPlacement.top,
                          .bottom, .leading, .trailing] {
            let c = TooltipContainer<Text>(tooltip: tooltip, placement: placement) {
                Text("content")
            }
            _ = c.body
        }
    }

    @Test func viewExtensionWrapsContent() {
        let tooltip = ContextualTooltip(message: "msg", onDismiss: {})
        let wrapped = Text("hello").contextualTooltip(tooltip, placement: .bottom)
        _ = wrapped
    }

    @Test func viewExtensionAcceptsNilTooltip() {
        let wrapped = Text("hello").contextualTooltip(nil)
        _ = wrapped
    }
}
