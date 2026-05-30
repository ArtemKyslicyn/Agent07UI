import Testing
import SwiftUI
@testable import Agent07UI

struct TooltipTests {

    // MARK: - ContextualTooltip

    @Test @MainActor func testContextualTooltipInit() {
        let tooltip = ContextualTooltip(
            message: "Test message",
            icon: "lightbulb.fill",
            arrowDirection: .up,
            onDismiss: {},
            onDontShowAgain: {}
        )
        #expect(tooltip.message == "Test message")
        #expect(tooltip.icon == "lightbulb.fill")
        #expect(tooltip.arrowDirection == .up)
    }

    @Test @MainActor func testContextualTooltipDefaultIcon() {
        let tooltip = ContextualTooltip(
            message: "Test",
            onDismiss: {}
        )
        #expect(tooltip.icon == "lightbulb.fill")
    }

    @Test @MainActor func testContextualTooltipNoIcon() {
        let tooltip = ContextualTooltip(
            message: "Test",
            icon: nil,
            onDismiss: {}
        )
        #expect(tooltip.icon == nil)
    }

    @Test @MainActor func testContextualTooltipArrowDirections() {
        let up = ContextualTooltip.ArrowDirection.up
        let down = ContextualTooltip.ArrowDirection.down
        let leading = ContextualTooltip.ArrowDirection.leading
        let trailing = ContextualTooltip.ArrowDirection.trailing

        #expect(up == .up)
        #expect(down == .down)
        #expect(leading == .leading)
        #expect(trailing == .trailing)
    }

    @Test @MainActor func testContextualTooltipLongMessage() {
        let longMessage = String(repeating: "This is a very long message. ", count: 10)
        let tooltip = ContextualTooltip(
            message: longMessage,
            onDismiss: {}
        )
        #expect(tooltip.message == longMessage)
    }

    @Test @MainActor func testContextualTooltipWithoutDontShowAgain() {
        let tooltip = ContextualTooltip(
            message: "Test",
            onDismiss: {}
        )
        #expect(tooltip.onDontShowAgain == nil)
    }

    // MARK: - TooltipContainer

    @Test @MainActor func testTooltipContainerWithTooltip() {
        let tooltip = ContextualTooltip(message: "Test", onDismiss: {})
        let container = TooltipContainer(tooltip: tooltip, placement: .top) {
            Text("Content")
        }
        #expect(container.tooltip != nil)
        #expect(container.placement == .top)
    }

    @Test @MainActor func testTooltipContainerWithoutTooltip() {
        let container = TooltipContainer<Text>(tooltip: nil, placement: .bottom) {
            Text("Content")
        }
        #expect(container.tooltip == nil)
    }

    @Test @MainActor func testTooltipContainerPlacements() {
        let top = TooltipContainer<Text>.TooltipPlacement.top
        let bottom = TooltipContainer<Text>.TooltipPlacement.bottom
        let leading = TooltipContainer<Text>.TooltipPlacement.leading
        let trailing = TooltipContainer<Text>.TooltipPlacement.trailing

        #expect(top == .top)
        #expect(bottom == .bottom)
        #expect(leading == .leading)
        #expect(trailing == .trailing)
    }

    // MARK: - HelpItem

    @Test func testHelpItemInit() {
        let item = HelpItem(
            id: "test",
            title: "Test Item",
            description: "Test description",
            category: .commands,
            icon: "command.circle",
            keywords: ["test", "sample"]
        )
        #expect(item.id == "test")
        #expect(item.title == "Test Item")
        #expect(item.description == "Test description")
        #expect(item.category == .commands)
        #expect(item.icon == "command.circle")
        #expect(item.keywords == ["test", "sample"])
    }

    @Test func testHelpItemDefaultIcon() {
        let item = HelpItem(
            id: "test",
            title: "Test",
            description: "Desc",
            category: .features
        )
        #expect(item.icon == "questionmark.circle")
    }

    @Test func testHelpItemMatchesEmptyQuery() {
        let item = HelpItem(
            id: "test",
            title: "Test",
            description: "Description",
            category: .commands
        )
        #expect(item.matches("") == true)
    }

    @Test func testHelpItemMatchesTitle() {
        let item = HelpItem(
            id: "test",
            title: "Pipeline Editor",
            description: "Edit workflows",
            category: .features
        )
        #expect(item.matches("pipeline") == true)
        #expect(item.matches("PIPELINE") == true)
        #expect(item.matches("Editor") == true)
    }

    @Test func testHelpItemMatchesDescription() {
        let item = HelpItem(
            id: "test",
            title: "Tool",
            description: "Edit workflows",
            category: .features
        )
        #expect(item.matches("workflow") == true)
        #expect(item.matches("edit") == true)
    }

    @Test func testHelpItemMatchesKeywords() {
        let item = HelpItem(
            id: "test",
            title: "Tool",
            description: "Description",
            category: .features,
            keywords: ["automation", "pipeline", "agent"]
        )
        #expect(item.matches("automation") == true)
        #expect(item.matches("agent") == true)
        #expect(item.matches("auto") == true) // partial match
    }

    @Test func testHelpItemMatchesCategory() {
        let item = HelpItem(
            id: "test",
            title: "Tool",
            description: "Description",
            category: .commands
        )
        #expect(item.matches("commands") == true)
        #expect(item.matches("Commands") == true)
    }

    @Test func testHelpItemDoesNotMatch() {
        let item = HelpItem(
            id: "test",
            title: "Pipeline",
            description: "Edit workflows",
            category: .features
        )
        #expect(item.matches("nonexistent") == false)
    }

    // MARK: - HelpCategory

    @Test func testHelpCategoryAllCases() {
        let categories = HelpCategory.allCases
        #expect(categories.count == 5)
        #expect(categories.contains(.commands))
        #expect(categories.contains(.features))
        #expect(categories.contains(.shortcuts))
        #expect(categories.contains(.tutorials))
        #expect(categories.contains(.troubleshooting))
    }

    @Test func testHelpCategoryRawValues() {
        #expect(HelpCategory.commands.rawValue == "commands")
        #expect(HelpCategory.features.rawValue == "features")
        #expect(HelpCategory.shortcuts.rawValue == "shortcuts")
        #expect(HelpCategory.tutorials.rawValue == "tutorials")
        #expect(HelpCategory.troubleshooting.rawValue == "troubleshooting")
    }

    @Test func testHelpCategoryIcons() {
        #expect(HelpCategory.commands.icon == "command.circle")
        #expect(HelpCategory.features.icon == "sparkles")
        #expect(HelpCategory.shortcuts.icon == "keyboard")
        #expect(HelpCategory.tutorials.icon == "book.circle")
        #expect(HelpCategory.troubleshooting.icon == "wrench.and.screwdriver")
    }

    // MARK: - HelpPanel

    @Test @MainActor func testHelpPanelInit() {
        let items = [
            HelpItem(id: "1", title: "Item 1", description: "Desc 1", category: .commands),
            HelpItem(id: "2", title: "Item 2", description: "Desc 2", category: .features)
        ]
        let panel = HelpPanel(
            isPresented: .constant(true),
            items: items
        )
        #expect(panel.items.count == 2)
    }

    @Test @MainActor func testHelpPanelWithEmptyItems() {
        let panel = HelpPanel(
            isPresented: .constant(true),
            items: []
        )
        #expect(panel.items.isEmpty)
    }

    // MARK: - TutorialStep

    @Test func testDefaultTutorialStepInit() {
        let step = DefaultTutorialStep(
            id: "step1",
            title: "First Step",
            description: "This is the first step",
            icon: "1.circle"
        )
        #expect(step.id == "step1")
        #expect(step.title == "First Step")
        #expect(step.description == "This is the first step")
        #expect(step.icon == "1.circle")
    }

    @Test func testDefaultTutorialStepNoIcon() {
        let step = DefaultTutorialStep(
            id: "step1",
            title: "First Step",
            description: "Description"
        )
        #expect(step.icon == nil)
    }

    @Test func testDefaultTutorialStepIdentifiable() {
        let step1 = DefaultTutorialStep(id: "1", title: "A", description: "B")
        let step2 = DefaultTutorialStep(id: "2", title: "C", description: "D")
        #expect(step1.id != step2.id)
    }

    // MARK: - TutorialOverlay

    @Test @MainActor func testTutorialOverlayInit() {
        let steps = [
            DefaultTutorialStep(id: "1", title: "Step 1", description: "First"),
            DefaultTutorialStep(id: "2", title: "Step 2", description: "Second")
        ]
        let overlay = TutorialOverlay(
            steps: steps,
            onComplete: {},
            onDismiss: {}
        )
        #expect(overlay.steps.count == 2)
    }

    @Test @MainActor func testTutorialOverlayWithSingleStep() {
        let steps = [
            DefaultTutorialStep(id: "1", title: "Only Step", description: "Description")
        ]
        let overlay = TutorialOverlay(
            steps: steps,
            onComplete: {},
            onDismiss: {}
        )
        #expect(overlay.steps.count == 1)
    }

    @Test @MainActor func testTutorialOverlayWithMultipleSteps() {
        let steps = (1...5).map {
            DefaultTutorialStep(id: "\($0)", title: "Step \($0)", description: "Description \($0)")
        }
        let overlay = TutorialOverlay(
            steps: steps,
            onComplete: {},
            onDismiss: {}
        )
        #expect(overlay.steps.count == 5)
    }

    @Test @MainActor func testTutorialOverlayWithCustomStepContent() {
        let steps = [
            DefaultTutorialStep(id: "1", title: "Step", description: "Desc")
        ]
        let overlay = TutorialOverlay(
            steps: steps,
            onComplete: {},
            onDismiss: {}
        ) { step in
            Text(step.title)
        }
        #expect(overlay.steps.count == 1)
    }

    // MARK: - Integration Tests

    @Test @MainActor func testContextualTooltipInstantiation() {
        let tooltip = ContextualTooltip(
            message: "Welcome to the feature",
            icon: "star.fill",
            arrowDirection: .down,
            onDismiss: {},
            onDontShowAgain: {}
        )
        _ = tooltip.body // Just verify it doesn't crash
    }

    @Test @MainActor func testTooltipContainerInstantiation() {
        let tooltip = ContextualTooltip(message: "Test", onDismiss: {})
        let container = TooltipContainer(tooltip: tooltip) {
            Text("Content")
        }
        _ = container.body // Just verify it doesn't crash
    }

    @Test @MainActor func testHelpPanelInstantiation() {
        let items = [
            HelpItem(id: "1", title: "Test", description: "Description", category: .commands)
        ]
        let panel = HelpPanel(isPresented: .constant(true), items: items)
        _ = panel.body // Just verify it doesn't crash
    }

    @Test @MainActor func testTutorialOverlayInstantiation() {
        let steps = [
            DefaultTutorialStep(id: "1", title: "Step", description: "Description")
        ]
        let overlay = TutorialOverlay(steps: steps, onComplete: {}, onDismiss: {})
        _ = overlay.body // Just verify it doesn't crash
    }
}
