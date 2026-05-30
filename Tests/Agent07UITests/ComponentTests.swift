import Testing
import SwiftUI
@testable import Agent07UI

struct UIComponentTests {

    // MARK: - CodeMinimap

    @Test func testCodeMinimapInit() {
        let minimap = CodeMinimap(content: "func hello() {}", currentLine: 1, language: "swift")
        #expect(minimap.content == "func hello() {}")
        #expect(minimap.currentLine == 1)
        #expect(minimap.language == "swift")
    }

    @Test func testCodeMinimapLargeContent() {
        let content = (1...100).map { "func line\($0)() {}" }.joined(separator: "\n")
        let minimap = CodeMinimap(content: content, currentLine: 50, language: "swift")
        #expect(minimap.currentLine == 50)
    }

    @Test func testCodeMinimapEmptyContent() {
        let minimap = CodeMinimap(content: "", currentLine: 0, language: "text")
        #expect(minimap.content.isEmpty)
    }

    // MARK: - SplitDiffEditor

    @Test func testSplitDiffEditorInit() {
        let editor = SplitDiffEditorView(leftPath: "/tmp/a.txt", rightPath: "/tmp/b.txt")
        #expect(editor.leftPath == "/tmp/a.txt")
        #expect(editor.rightPath == "/tmp/b.txt")
    }

    @Test func testDiffEditorLineType() {
        let same = SplitDiffEditorView.DiffEditorLine(number: 1, text: "same", type: .same)
        let added = SplitDiffEditorView.DiffEditorLine(number: 2, text: "new", type: .added)
        let removed = SplitDiffEditorView.DiffEditorLine(number: nil, text: "old", type: .removed)
        let empty = SplitDiffEditorView.DiffEditorLine(number: nil, text: "", type: .empty)

        #expect(same.type == .same)
        #expect(added.type == .added)
        #expect(removed.number == nil)
        #expect(empty.text.isEmpty)
    }

    // MARK: - Theme

    @Test @MainActor func testThemeColors() {
        #expect(Theme.surface != Theme.elevated)
        #expect(Theme.accent != Theme.error)
    }

    @Test @MainActor func testThemeFonts() {
        let title = Theme.titleFont
        let body = Theme.bodyFont
        let mono = Theme.monoFont
        // Just verify they exist
        _ = title; _ = body; _ = mono
    }

    @Test @MainActor func testThemeSpacing() {
        #expect(Theme.spacing4 == 4)
        #expect(Theme.spacing8 == 8)
        #expect(Theme.spacing16 == 16)
    }

    // MARK: - ThemedComponents

    @Test @MainActor func testStatusBadgeIdle() {
        let badge = StatusBadge(status: .idle)
        _ = badge // Just verify instantiation
    }

    @Test @MainActor func testThemedEmptyState() {
        let empty = ThemedEmptyState(icon: "doc", title: "No files", subtitle: "Open a project")
        _ = empty
    }
}
