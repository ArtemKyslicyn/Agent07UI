//
//  UIViewSmokeTests.swift
//  Agent07UITests
//
//  Smoke + pure-logic coverage for 4 SwiftUI views that had 0% line
//  coverage. SwiftUI `body` rendering needs ViewInspector or the host
//  app to exercise — but init paths, public extension properties, and
//  the value types nested inside each view ARE testable directly.
//

import Testing
import Foundation
import SwiftUI
@testable import Agent07UI

// CompactionTimelineView / CompactionPhase extension / ContextMetricsView /
// PrivacyIndicator tests removed in the public extraction — those views
// depend on telemetry/privacy types from the Agent07 monorepo. The remaining
// SplitDiffEditorView block below is fully generic and stays here.

// MARK: - SplitDiffEditorView

@MainActor
@Suite("SplitDiffEditorView")
struct SplitDiffEditorViewTests {

    @Test func initWithTwoPaths() {
        let view = SplitDiffEditorView(leftPath: "/tmp/old.txt",
                                        rightPath: "/tmp/new.txt")
        _ = view.body
        #expect(view.leftPath == "/tmp/old.txt")
        #expect(view.rightPath == "/tmp/new.txt")
    }

    @Test func diffEditorLineIdentifiable() {
        let line = SplitDiffEditorView.DiffEditorLine(
            number: 1, text: "let x = 1",
            type: .added
        )
        #expect(line.number == 1)
        #expect(line.text == "let x = 1")
        #expect(line.type == .added)
    }

    @Test func lineTypeAllCases() {
        // Touches every case of the nested enum.
        let types: [SplitDiffEditorView.DiffEditorLine.LineType] = [
            .same, .added, .removed, .empty
        ]
        #expect(types.count == 4)
    }

    @Test func twoDifferentLinesHaveDifferentIDs() {
        let a = SplitDiffEditorView.DiffEditorLine(number: 1, text: "a", type: .same)
        let b = SplitDiffEditorView.DiffEditorLine(number: 2, text: "b", type: .same)
        #expect(a.id != b.id)
    }
}
