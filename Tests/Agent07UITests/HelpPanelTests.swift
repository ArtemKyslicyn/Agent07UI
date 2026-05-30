//
//  HelpPanelTests.swift
//  Agent07UITests
//
//  Coverage for HelpItem (init defaults + matches search) and the
//  HelpCategory localizedName mapping. HelpPanel view init is also
//  exercised via init paths.
//

import Testing
import Foundation
import SwiftUI
@testable import Agent07UI

@Suite("HelpItem")
struct HelpItemTests {

    @Test func initWithDefaults() {
        let item = HelpItem(id: "1", title: "T", description: "D", category: .commands)
        #expect(item.id == "1")
        #expect(item.title == "T")
        #expect(item.description == "D")
        #expect(item.category == .commands)
        #expect(item.icon == "questionmark.circle")  // default
        #expect(item.keywords.isEmpty)               // default
    }

    @Test func initWithExplicitIconAndKeywords() {
        let item = HelpItem(id: "x", title: "Edit", description: "Open editor",
                             category: .commands,
                             icon: "pencil",
                             keywords: ["modify", "change"])
        #expect(item.icon == "pencil")
        #expect(item.keywords == ["modify", "change"])
    }

    @Test func emptyQueryMatchesAnyItem() {
        let item = HelpItem(id: "1", title: "Anything",
                             description: "Anywhere",
                             category: .features)
        #expect(item.matches(""))
    }

    @Test func queryMatchesTitleSubstring() {
        let item = HelpItem(id: "1", title: "Save File",
                             description: "Persist current buffer",
                             category: .commands)
        #expect(item.matches("save"))
        #expect(item.matches("FILE"))     // case-insensitive
        #expect(!item.matches("delete"))
    }

    @Test func queryMatchesDescriptionSubstring() {
        let item = HelpItem(id: "1", title: "Whatever",
                             description: "Sync changes to remote",
                             category: .features)
        #expect(item.matches("Sync"))
        #expect(item.matches("remote"))
    }

    @Test func queryMatchesKeyword() {
        let item = HelpItem(id: "1", title: "X", description: "Y",
                             category: .shortcuts,
                             keywords: ["copy", "duplicate"])
        #expect(item.matches("duplicate"))
        #expect(item.matches("COPY"))
    }

    @Test func queryMatchesLocalizedCategoryName() {
        // HelpCategory.commands → localizedName "Commands"
        let item = HelpItem(id: "1", title: "X", description: "Y",
                             category: .commands)
        #expect(item.matches("Commands"))
    }
}

@Suite("HelpCategory localizedName")
struct HelpCategoryLocalizedNameTests {

    @Test func allCasesHaveNonEmptyLocalizedName() {
        for category in HelpCategory.allCases {
            #expect(!category.localizedName.isEmpty)
        }
    }

    @Test func localizedNameMatchesEnglishBaseline() {
        // The base catalog uses English Title Case — explicit values to
        // catch accidental rename / l10n drift.
        #expect(HelpCategory.commands.localizedName == "Commands")
        #expect(HelpCategory.features.localizedName == "Features")
        #expect(HelpCategory.shortcuts.localizedName == "Shortcuts")
        #expect(HelpCategory.tutorials.localizedName == "Tutorials")
        #expect(HelpCategory.troubleshooting.localizedName == "Troubleshooting")
    }
}

@MainActor
@Suite("HelpPanel")
struct HelpPanelInitTests {

    @Test func initWithEmptyItems() {
        @State var isPresented = true
        let panel = HelpPanel(
            isPresented: Binding(get: { isPresented }, set: { isPresented = $0 }),
            items: []
        )
        _ = panel.body
    }

    @Test func initWithItemsAndSelectionCallback() {
        let items = [
            HelpItem(id: "1", title: "Save", description: "Save the file",
                     category: .commands),
            HelpItem(id: "2", title: "Find", description: "Find in file",
                     category: .shortcuts, keywords: ["search"])
        ]
        @State var isPresented = true
        var capturedItemId: String?
        let panel = HelpPanel(
            isPresented: Binding(get: { isPresented }, set: { isPresented = $0 }),
            items: items,
            onSelectItem: { capturedItemId = $0.id }
        )
        _ = panel.body
        _ = capturedItemId  // closure stored, not invoked here
    }
}
