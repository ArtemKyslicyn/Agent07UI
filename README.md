# Agent07UI

A drop-in SwiftUI design system for macOS apps. Dark-first theme tokens,
a small set of well-tested themed components, contextual onboarding bits
(tooltips, tutorial overlays, help panel), and a couple of utility views
for code rendering and diffs.

[![CI](https://github.com/ArtemKyslicyn/Agent07UI/actions/workflows/ci.yml/badge.svg)](https://github.com/ArtemKyslicyn/Agent07UI/actions/workflows/ci.yml)
[![Swift 6](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%2014%2B%20%7C%20iOS%2017%2B-blue.svg)](#)
[![SPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](#install)
[![Tests](https://img.shields.io/badge/Tests-142%20passing-success.svg)](#testing)
[![Coverage](https://img.shields.io/badge/Coverage-57%25-yellow.svg)](#testing)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## About

**Agent07UI is the public design-system layer of the [Agent07](https://github.com/ArtemKyslicyn/Agent07)
open-core architecture.** Agent07 is a macOS app (Swift 6 / SwiftUI)
split into modular Swift Package Manager packages; this one holds the
presentation primitives — the theme tokens, skins, reusable themed
components, tooltips, and the tutorial overlay — that the app target and
the other UI-facing packages all consume.

It is intentionally the *bottom* of the UI stack:

- **No package dependencies.** `Package.swift` declares zero
  dependencies — not even sibling packages such as `Agent07Domain` or
  `Agent07Foundation`. It links only the system frameworks (SwiftUI +
  AppKit on macOS / UIKit on iOS). That keeps it a leaf node that
  anything can depend on without pulling in domain logic.
- **A single product**, `Agent07UI`, exporting one `Agent07UI` target.
- **Drop-in outside Agent07 too.** Nothing here is Agent07-specific, so
  it works as a standalone SwiftUI toolkit for any macOS 14+ / iOS 17+ app.

## Why

Most SwiftUI apps end up reinventing the same primitives: a card with a
hover state, a status badge, a token-usage bar, a tooltip that remembers
"don't show again." This package extracts that surface from a working
macOS app ([Agent07](https://github.com/ArtemKyslicyn/Agent07)) into a
self-contained, **dependency-free** library so other projects can skip
straight to building features.

- **Zero runtime deps.** Only SwiftUI + AppKit/UIKit. No Combine, no
  third-party packages.
- **Theme tokens, not hard-coded colors.** Every component reads from
  `Theme.*`, so a single property change re-skins everything.
- **Swift 6 strict concurrency.** All types are `Sendable`; all
  observable state is `@MainActor`.
- **Accessibility-aware.** Every interactive component ships explicit
  `.accessibilityLabel` / `.accessibilityHint` text and combines
  child elements where it makes the screen-reader output cleaner.

## Install

```swift
.package(url: "https://github.com/ArtemKyslicyn/Agent07UI.git",
         from: "0.1.0")
```

Then in your target:

```swift
.product(name: "Agent07UI", package: "Agent07UI")
```

```swift
import Agent07UI
```

## Components

### Theme — design tokens

`Theme` is an `enum` namespace of design tokens. It is the source of
truth for every other component in the package — change a Theme value
and everything re-skins.

```swift
// Surface colors (auto-switched by Theme.mode = .light / .dark)
Theme.surface         // window background
Theme.primary         // base surface
Theme.secondary       // slightly raised surface
Theme.tertiary        // muted cards
Theme.elevated        // raised surface (cards, sheets)
Theme.hover           // hover background

// Accent + semantic colors
Theme.accent          // brand accent
Theme.accentDim       // accent at 60% opacity
Theme.success / .warning / .error / .info

// Text colors
Theme.textPrimary     // body text
Theme.textSecondary   // de-emphasised text
Theme.textTertiary    // captions
Theme.textMuted       // disabled / placeholder

// Borders
Theme.border          // hairline borders
Theme.borderActive    // focused/selected borders (== accent)

// Spacing scale (4-point grid)
Theme.spacing4 / spacing8 / spacing12 / spacing16

// Corner radii
Theme.radius4 / radius8 / radius12

// Type ramp (Dynamic Type-backed, scales to AX5)
Theme.titleFont / bodyFont / captionFont / tinyFont
Theme.monoFont / monoSmall   // monospaced variants for code

// Apply the package's appearance to the running app (macOS)
Theme.applyAppearance()       // @MainActor

// Light/dark switching (persisted via @AppStorage("themeMode"))
@AppStorage("themeMode") var mode: ThemeMode = .dark
Theme.isDark                  // resolved Bool for the current mode
```

#### WCAG color-contrast verifier

`Theme` ships a small, pure-Swift WCAG 2.1 contrast toolkit so you can
assert (or unit-test) that any foreground/background pairing is legible.
All functions return `nil` only when a `Color` can't be resolved to sRGB
components on the current platform.

```swift
Theme.rgbComponents(from: color)                  // (red, green, blue)? in 0...1
Theme.relativeLuminance(of: color)                // Double? per WCAG
Theme.contrastRatio(between: fg, and: bg)          // Double? 1.0...21.0

Theme.meetsAAText(foreground: fg, background: bg)       // ≥ 4.5:1 (normal text)
Theme.meetsAALargeText(foreground: fg, background: bg)  // ≥ 3.0:1 (18pt+ / 14pt bold)
Theme.meetsAAGraphics(foreground: fg, background: bg)   // ≥ 3.0:1 (UI components)
```

These are exactly the helpers the test suite uses to guard the built-in
palette against contrast regressions in both light and dark modes.

### `ThemedCard` — content card with hover + selection states

```swift
ThemedCard(isSelected: false, isHovered: false) {
    VStack(alignment: .leading) {
        Text("Title")
        Text("Subtitle").foregroundStyle(Theme.textSecondary)
    }
}
```

Selection state automatically maps to `.isSelected` accessibility trait
and a brighter border. Hover state cross-fades the background.

### `ThemedSectionLabel` — small uppercase header

```swift
ThemedSectionLabel("Settings")
```

### `ThemedButton` — compact action button

```swift
ThemedButton("Run", icon: "play.fill", tint: .accentColor) {
    runTask()
}
// or without icon:
ThemedButton("Cancel") { dismiss() }
```

Icons are SF Symbols. Accessibility label is generated as
"`{title} button with {icon} icon`" / "`{title} button`".

### `ThemedEmptyState` — zero-state with optional CTA

```swift
ThemedEmptyState(
    icon: "tray",
    title: "No items",
    subtitle: "Drop something here to get started.",
    action: { /* … */ },
    actionTitle: "Add item"
)
```

When `action` is nil the CTA is hidden; the rest of the layout stays.

### `StatusBadge` — execution status indicator

Backed by a local `ExecutionStatus` enum (`.idle / .running / .success
/ .error`). Renders a circle, label, and optional duration.

```swift
StatusBadge(status: .running)
StatusBadge(status: .success, duration: 1.43) // "Done (1.4s)"
StatusBadge(status: .error)
```

### `LinearProgressBar` — token / progress meter

```swift
LinearProgressBar(value: 0.65, tint: .green)
LinearProgressBar(value: 0.85, tint: .yellow, trackOpacity: 0.2, height: 8)
```

`value` is clamped to `0...1` internally; tint colors and height are
configurable.

### `Color` helpers

```swift
Color(w: 0.5)        // grayscale (NS/UI-color backed)
Color(hex: "#3A5F8C")  // 6-hex with or without leading "#"; returns nil
Color(hex: "ABC")    // → nil  (only 3 chars after #)
Color(hex: "GGGGGG") // → nil  (not valid hex)
myColor.hexString    // round-trip back to "#RRGGBB" (uppercase)
```

### `HelpPanel` — searchable command/topic reference

```swift
@State private var showHelp = false

HelpPanel(
    isPresented: $showHelp,
    items: [
        HelpItem(id: "save", title: "Save File",
                 description: "Persists the current buffer",
                 category: .commands,
                 keywords: ["write", "store"]),
        // …
    ],
    onSelectItem: { item in
        showHelp = false
        run(item.id)
    }
)
```

`HelpItem.matches(_:)` is case-insensitive and searches the title,
description, keywords, and the localised category name. The category
enum is `.commands / .features / .shortcuts / .tutorials /
.troubleshooting`, each with an SF Symbol icon and a String catalog
display name.

### `ContextualTooltip` — one-time discoverability hints

```swift
ContextualTooltip(
    message: "Press ⌘K to open the command palette.",
    icon: "lightbulb.fill",
    arrowDirection: .down,
    onDismiss: { dismissTooltip() },
    onDontShowAgain: { permanentlyDismiss() }
)
```

Or attach to any view with the `.contextualTooltip(_:placement:)`
modifier:

```swift
PaletteButton()
    .contextualTooltip(showCommandPaletteHint
                       ? ContextualTooltip(
                           message: "Press ⌘K", onDismiss: dismiss)
                       : nil,
                       placement: .bottom)
```

Placements: `.top / .bottom / .leading / .trailing`.

### `TutorialOverlay` — step-by-step onboarding

```swift
TutorialOverlay(
    steps: [
        DefaultTutorialStep(id: "1", title: "Welcome",
                             description: "Take a quick tour"),
        DefaultTutorialStep(id: "2", title: "Editor",
                             description: "Open files with ⌘P",
                             icon: "doc.text")
    ],
    onComplete: { markComplete() },
    onDismiss:  { dismissTour() },
    stepContent: { step in
        VStack {
            if let icon = step.icon {
                Image(systemName: icon).font(.largeTitle)
            }
            Text(step.title).font(.title2)
            Text(step.description)
        }
    }
)
```

Generic over both `Step: TutorialStep` (so callers can use richer types
than `DefaultTutorialStep`) and `StepContent: View`.

### `SplitDiffEditorView` — side-by-side file diff

```swift
SplitDiffEditorView(leftPath: "/path/to/old.swift",
                    rightPath: "/path/to/new.swift")
```

Reads both files, computes a line-by-line diff, and renders two
synchronised scroll columns with red/green tinted backgrounds. Nested
`DiffEditorLine` and `LineType` (`.same / .added / .removed / .empty`)
are part of the public API for callers building their own diff
visualizers on top.

### `CodeMinimap` — overview rail for long code views

```swift
CodeMinimap(content: sourceText,
            currentLine: cursorLine,
            language: "swift")
```

A vertical rail that scales code content down to a thumbnail, with
sync-scrolled highlighting of the `currentLine`. Drops into any code
editor as the right-edge rail. `language` is used to tune the syntax
tinting.

## Public API surface (cheat sheet)

```
Theme + ThemeMode                        — design tokens, light/dark switch
Theme.applyAppearance() / Theme.isDark   — apply skin, resolve current mode
Theme contrast verifier                  — contrastRatio / meetsAAText /
                                           meetsAALargeText / meetsAAGraphics /
                                           relativeLuminance / rgbComponents
Color(w:) / Color(hex:) / .hexString     — Color extensions
ThemedCard                               — card surface
ThemedSectionLabel                       — section header
ThemedButton                             — compact button
ThemedEmptyState                         — zero-state layout
StatusBadge                              — execution status indicator
ExecutionStatus (.idle/.running/.success/.error)
LinearProgressBar                        — progress meter
HelpItem + HelpCategory + HelpPanel      — searchable help reference
ContextualTooltip + .contextualTooltip() — discoverability hints
TooltipContainer / TooltipPlacement
TutorialStep + DefaultTutorialStep
TutorialOverlay                          — onboarding steps
SplitDiffEditorView + DiffEditorLine     — side-by-side diff (+ LineType)
CodeMinimap                              — code overview rail
```

## Testing

```bash
swift test
```

Written with the [Swift Testing](https://developer.apple.com/documentation/testing)
framework (`@Suite` / `@Test`), not XCTest. 142 tests across 21 suites,
**57% line coverage**, all green. The suite covers:

- Light + dark theme contrast, asserted through the built-in WCAG
  verifier (`Theme.contrastRatio` / `meetsAAText` / `meetsAALargeText` /
  `meetsAAGraphics`) — AA minimum, AAA where possible
- `relativeLuminance` / `rgbComponents` edge cases (incl. unresolvable colors)
- Color helper round-trips (`hex` → `hexString` → back)
- Every `ExecutionStatus` case rendering in `StatusBadge`
- All themed component init paths (defaults + every optional)
- `HelpItem.matches` against title / description / keywords / category
  name, case-insensitive
- All four `ContextualTooltip.ArrowDirection` values
- All four `TooltipPlacement` values, both with and without a tooltip
- Tutorial overlay with empty + multi-step lists
- Help category baseline English names (catches l10n drift)
- `SplitDiffEditorView` init + nested `DiffEditorLine` identity

The body-render branches of SwiftUI views are touched via `_ = view.body`
in tests, which instruments the `var body: some View` getter without
requiring `ViewInspector` or a host app.

## Origin

Extracted from [Agent07](https://github.com/ArtemKyslicyn/Agent07) in
2026-05. Designed to be drop-in for any macOS / iOS Swift app that
wants a small, opinionated SwiftUI toolkit without an icon-and-color
shopping spree.

## Contributing

Issues and pull requests welcome. The Swift 6 strict-concurrency
checker is enforced — all public types are `Sendable`, and every
observable state holder is `@MainActor`.

## License

MIT — see [LICENSE](LICENSE).
