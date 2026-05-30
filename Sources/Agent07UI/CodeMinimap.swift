//
//  CodeMinimap.swift
//  Agent07
//
//  Miniature code preview for navigation in the editor.
//  Shows condensed view of the entire file with current position indicator.
//

import SwiftUI

public struct CodeMinimap: View {
    public let content: String
    public let currentLine: Int
    public let language: String

    public init(content: String, currentLine: Int, language: String) {
        self.content = content; self.currentLine = currentLine; self.language = language
    }

    private var lines: [String] {
        content.components(separatedBy: "\n")
    }

    private var totalLines: Int { lines.count }

    public var body: some View {
        GeometryReader { geo in
            let availableHeight = geo.size.height
            let lineHeight: CGFloat = max(1.5, min(3, availableHeight / CGFloat(max(totalLines, 1))))
            let viewportLines = Int(availableHeight / lineHeight)
            let currentLineNorm = max(0, min(currentLine - 1, totalLines - 1))

            ZStack(alignment: .topLeading) {
                // Code preview
                Canvas { context, size in
                    for (i, line) in lines.enumerated() {
                        let y = CGFloat(i) * lineHeight
                        guard y < size.height else { break }

                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { continue }

                        // Indent level → x offset
                        let indent = CGFloat(line.prefix(while: { $0 == " " }).count) * 1.5
                        let width = min(CGFloat(trimmed.count) * 0.8, size.width - indent - 2)

                        let color = lineColor(trimmed)
                        let rect = CGRect(x: indent + 1, y: y, width: max(2, width), height: lineHeight - 0.5)
                        context.fill(Path(rect), with: .color(color))
                    }
                }

                // Viewport indicator
                let indicatorY = CGFloat(currentLineNorm) * lineHeight - CGFloat(viewportLines / 2) * lineHeight
                let clampedY = max(0, min(indicatorY, availableHeight - 40))
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.cyan.opacity(0.15))
                    .frame(width: geo.size.width, height: 40)
                    .offset(y: clampedY)
            }
        }
        .background(Theme.primary.opacity(0.5))
    }

    private func lineColor(_ line: String) -> Color {
        if line.hasPrefix("func ") || line.hasPrefix("def ") || line.hasPrefix("function ") {
            return .cyan.opacity(0.6)
        }
        if line.hasPrefix("class ") || line.hasPrefix("struct ") || line.hasPrefix("enum ") || line.hasPrefix("protocol ") {
            return .purple.opacity(0.6)
        }
        if line.hasPrefix("import ") || line.hasPrefix("from ") || line.hasPrefix("require") {
            return .orange.opacity(0.5)
        }
        if line.hasPrefix("//") || line.hasPrefix("#") || line.hasPrefix("/*") {
            return .green.opacity(0.3)
        }
        if line.hasPrefix("@") {
            return .yellow.opacity(0.5)
        }
        return .primary.opacity(0.25)
    }
}
