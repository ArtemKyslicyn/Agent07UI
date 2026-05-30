//
//  HelpPanel.swift
//  Agent07UI
//
//  Searchable help panel with keyboard navigation (Cmd+?).
//  Displays documentation, commands, and quick reference topics.
//

import SwiftUI

// MARK: - Help Item

/// A single help topic or command reference item
public struct HelpItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let category: HelpCategory
    public let icon: String
    public let keywords: [String]

    public init(
        id: String,
        title: String,
        description: String,
        category: HelpCategory,
        icon: String = "questionmark.circle",
        keywords: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.icon = icon
        self.keywords = keywords
    }

    /// Check if this item matches the search query
    public func matches(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let lowercaseQuery = query.lowercased()

        return title.lowercased().contains(lowercaseQuery)
            || description.lowercased().contains(lowercaseQuery)
            || keywords.contains { $0.lowercased().contains(lowercaseQuery) }
            || category.localizedName.lowercased().contains(lowercaseQuery)
    }
}

// MARK: - Help Category

public enum HelpCategory: String, CaseIterable, Sendable {
    case commands
    case features
    case shortcuts
    case tutorials
    case troubleshooting

    var localizedName: String {
        switch self {
        case .commands: return String(localized: "Commands", comment: "Help category: commands and actions.")
        case .features: return String(localized: "Features", comment: "Help category: features and capabilities.")
        case .shortcuts: return String(localized: "Shortcuts", comment: "Help category: keyboard shortcuts.")
        case .tutorials: return String(localized: "Tutorials", comment: "Help category: tutorials and guides.")
        case .troubleshooting: return String(localized: "Troubleshooting", comment: "Help category: troubleshooting and problem solving.")
        }
    }

    var icon: String {
        switch self {
        case .commands: return "command.circle"
        case .features: return "sparkles"
        case .shortcuts: return "keyboard"
        case .tutorials: return "book.circle"
        case .troubleshooting: return "wrench.and.screwdriver"
        }
    }
}

// MARK: - Help Panel

/// Searchable help panel with keyboard navigation
public struct HelpPanel: View {
    @Binding var isPresented: Bool
    let items: [HelpItem]
    var onSelectItem: ((HelpItem) -> Void)?

    @State private var searchQuery: String = ""
    @State private var selectedIndex: Int = 0
    @State private var selectedCategory: HelpCategory?
    @FocusState private var isSearchFocused: Bool

    public init(
        isPresented: Binding<Bool>,
        items: [HelpItem],
        onSelectItem: ((HelpItem) -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.items = items
        self.onSelectItem = onSelectItem
    }

    private var filteredItems: [HelpItem] {
        items.filter { item in
            let matchesSearch = item.matches(searchQuery)
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    private var groupedItems: [(HelpCategory, [HelpItem])] {
        Dictionary(grouping: filteredItems, by: \.category)
            .sorted { $0.key.localizedName < $1.key.localizedName }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()
                .background(Theme.border)

            // Category filter
            categoryFilterView

            Divider()
                .background(Theme.border)

            // Content
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                contentView
            }
        }
        .frame(width: 600, height: 500)
        .background(Theme.primary)
        .clipShape(.rect(cornerRadius: Theme.radius12))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius12)
                .stroke(Theme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
        .onAppear {
            isSearchFocused = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .accessibilityLabel(String(localized: "Help panel", comment: "Help panel: accessibility label for the panel."))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: Theme.spacing12) {
            // Icon
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Theme.info)
                .accessibilityHidden(true)

            // Title
            Text("Help & Documentation", comment: "Help panel: main title.")
                .font(Theme.titleFont)
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            // Close button
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Close help panel", comment: "Help panel: close button accessibility label."))
            .keyboardShortcut(.escape, modifiers: [])
        }
        .padding(Theme.spacing16)
    }

    // MARK: - Category Filter

    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.spacing8) {
                // All categories
                categoryButton(title: String(localized: "All", comment: "Help panel: category filter to show all categories."), isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                    selectedIndex = 0
                }

                // Individual categories
                ForEach(HelpCategory.allCases, id: \.self) { category in
                    categoryButton(
                        title: category.localizedName,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                        selectedIndex = 0
                    }
                }
            }
            .padding(.horizontal, Theme.spacing16)
            .padding(.vertical, Theme.spacing12)
        }
    }

    private func categoryButton(
        title: String,
        icon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.spacing8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(Theme.captionFont.weight(isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Theme.accent.opacity(0.15) : Theme.secondary)
            .clipShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // MARK: - Content

    private var contentView: some View {
        VStack(spacing: 0) {
            // Search field
            searchFieldView

            Divider()
                .background(Theme.border)

            // Results
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: Theme.spacing12, pinnedViews: [.sectionHeaders]) {
                        ForEach(Array(groupedItems.enumerated()), id: \.element.0) { _, group in
                            Section {
                                ForEach(Array(group.1.enumerated()), id: \.element.id) { index, item in
                                    let globalIndex = flatIndex(for: item)
                                    helpItemRow(item, isSelected: globalIndex == selectedIndex)
                                        .id(item.id)
                                        .onTapGesture {
                                            handleSelectItem(item)
                                        }
                                }
                            } header: {
                                sectionHeader(group.0)
                            }
                        }
                    }
                    .padding(Theme.spacing16)
                }
                .onChange(of: selectedIndex) { _, newIndex in
                    if let item = itemAt(index: newIndex) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(item.id, anchor: .center)
                        }
                    }
                }
            }
        }
        .onKeyPress(.upArrow) {
            handleKeyNavigation(direction: -1)
            return .handled
        }
        .onKeyPress(.downArrow) {
            handleKeyNavigation(direction: 1)
            return .handled
        }
        .onKeyPress(.return) {
            if let item = itemAt(index: selectedIndex) {
                handleSelectItem(item)
            }
            return .handled
        }
    }

    private var searchFieldView: some View {
        HStack(spacing: Theme.spacing8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)

            TextField(text: $searchQuery, prompt: Text("Search help topics, commands...", comment: "Help panel: search field placeholder.")) {}
                .textFieldStyle(.plain)
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textPrimary)
                .focused($isSearchFocused)
                .onChange(of: searchQuery) { _, _ in
                    selectedIndex = 0
                }
                .accessibilityLabel(String(localized: "Search help", comment: "Help panel: search field accessibility label."))

            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Clear search", comment: "Help panel: clear search button accessibility label."))
            }
        }
        .padding(Theme.spacing12)
        .background(Theme.secondary)
    }

    private func sectionHeader(_ category: HelpCategory) -> some View {
        HStack(spacing: Theme.spacing8) {
            Image(systemName: category.icon)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)

            Text(category.localizedName)
                .font(Theme.captionFont.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)

            Spacer()
        }
        .padding(.vertical, Theme.spacing8)
        .background(Theme.primary)
    }

    private func helpItemRow(_ item: HelpItem, isSelected: Bool) -> some View {
        HStack(alignment: .top, spacing: Theme.spacing12) {
            // Icon
            Image(systemName: item.icon)
                .font(.system(size: 16))
                .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
                .frame(width: 24, height: 24)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(Theme.bodyFont.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)

                Text(item.description)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            // Chevron
            if isSelected {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(Theme.spacing12)
        .background(isSelected ? Theme.accent.opacity(0.1) : Theme.secondary)
        .clipShape(.rect(cornerRadius: Theme.radius8))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius8)
                .stroke(isSelected ? Theme.accent : .clear, lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityLabel("\(item.title). \(item.description)")
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Theme.spacing16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(Theme.textTertiary)

            Text("No results found", comment: "Help panel: empty state title when search has no matches.")
                .font(Theme.titleFont)
                .foregroundStyle(Theme.textPrimary)

            Text("Try a different search term or category", comment: "Help panel: empty state description.")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "No results found. Try a different search term or category", comment: "Help panel: empty state accessibility label."))
    }

    // MARK: - Helpers

    private func handleKeyNavigation(direction: Int) {
        let newIndex = selectedIndex + direction
        if newIndex >= 0 && newIndex < filteredItems.count {
            selectedIndex = newIndex
        }
    }

    private func handleSelectItem(_ item: HelpItem) {
        onSelectItem?(item)
    }

    private func flatIndex(for item: HelpItem) -> Int {
        filteredItems.firstIndex { $0.id == item.id } ?? 0
    }

    private func itemAt(index: Int) -> HelpItem? {
        guard index >= 0 && index < filteredItems.count else { return nil }
        return filteredItems[index]
    }
}

// MARK: - Preview

#if DEBUG
struct HelpPanel_Previews: PreviewProvider {
    static let sampleItems: [HelpItem] = [
        HelpItem(
            id: "cmd-palette",
            title: "Command Palette",
            description: "Press Cmd+K to open the command palette and quickly access all features.",
            category: .shortcuts,
            icon: "command.circle",
            keywords: ["keyboard", "quick", "search"]
        ),
        HelpItem(
            id: "pipeline",
            title: "Create Pipeline",
            description: "Chain multiple AI agents together to build complex workflows.",
            category: .tutorials,
            icon: "link.circle",
            keywords: ["agent", "workflow", "automation"]
        ),
        HelpItem(
            id: "chat-slash",
            title: "/chat Command",
            description: "Start a new chat session with an AI agent.",
            category: .commands,
            icon: "message.circle",
            keywords: ["conversation", "ai", "assistant"]
        ),
        HelpItem(
            id: "terminal",
            title: "Terminal Integration",
            description: "Execute commands and scripts directly from the AI assistant.",
            category: .features,
            icon: "terminal",
            keywords: ["bash", "shell", "command"]
        ),
        HelpItem(
            id: "mcp-connection",
            title: "MCP Server Connection",
            description: "Connect to external Model Context Protocol servers for extended capabilities.",
            category: .tutorials,
            icon: "server.rack",
            keywords: ["integration", "external", "api"]
        ),
        HelpItem(
            id: "error-fix",
            title: "Fix Build Errors",
            description: "Troubleshoot common build and compilation issues.",
            category: .troubleshooting,
            icon: "exclamationmark.triangle",
            keywords: ["error", "debug", "compile"]
        ),
    ]

    static var previews: some View {
        HelpPanel(
            isPresented: .constant(true),
            items: sampleItems
        ) { item in
            print("Selected: \(item.title)")
        }
        .background(Theme.surface)
    }
}
#endif
