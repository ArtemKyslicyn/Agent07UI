//
//  SplitDiffEditor.swift
//  Agent07
//
//  Side-by-side diff editor with syntax highlighting.
//  Shows two files or two versions with synchronized scrolling.
//

import SwiftUI

public struct SplitDiffEditorView: View {
    public let leftPath: String
    public let rightPath: String
    @State private var leftContent = ""
    @State private var rightContent = ""
    @State private var diffLines: [(left: DiffEditorLine, right: DiffEditorLine)] = []

    public struct DiffEditorLine: Identifiable {
        public let id = UUID()
        public let number: Int?
        public let text: String
        public let type: LineType
        public enum LineType { case same, added, removed, empty }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "doc.text.magnifyingglass").foregroundStyle(.cyan)
                Text("Diff Editor").font(.system(size: 12, weight: .semibold))
                Spacer()
                Text("\(diffLines.count) lines").font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
            }
            .padding(8)
            .background(Theme.surface)

            // File names
            HStack(spacing: 0) {
                Text(URL(fileURLWithPath: leftPath).lastPathComponent)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .padding(4).background(Color.red.opacity(0.05))
                Text(URL(fileURLWithPath: rightPath).lastPathComponent)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity)
                    .padding(4).background(Color.green.opacity(0.05))
            }

            Divider()

            // Diff content
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(diffLines.enumerated()), id: \.offset) { _, pair in
                        HStack(spacing: 0) {
                            diffLineView(pair.left).frame(maxWidth: .infinity)
                            Divider()
                            diffLineView(pair.right).frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .onAppear { computeDiff() }
    }

    private func diffLineView(_ line: DiffEditorLine) -> some View {
        HStack(spacing: 0) {
            Text(line.number.map { String(format: "%3d", $0) } ?? "   ")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary.opacity(0.5))
                .frame(width: 30)

            Text(line.text)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(lineColor(line.type))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 4).padding(.vertical, 1)
        .background(lineBg(line.type))
    }

    private func lineColor(_ type: DiffEditorLine.LineType) -> Color {
        switch type {
        case .same: return .primary.opacity(0.7)
        case .added: return .green
        case .removed: return .red
        case .empty: return .clear
        }
    }

    private func lineBg(_ type: DiffEditorLine.LineType) -> Color {
        switch type {
        case .added: return .green.opacity(0.08)
        case .removed: return .red.opacity(0.08)
        default: return .clear
        }
    }

    private func computeDiff() {
        leftContent = (try? String(contentsOfFile: leftPath, encoding: .utf8)) ?? ""
        rightContent = (try? String(contentsOfFile: rightPath, encoding: .utf8)) ?? ""

        let leftLines = leftContent.components(separatedBy: "\n")
        let rightLines = rightContent.components(separatedBy: "\n")

        // Simple line-by-line diff (LCS-based for proper alignment would be ideal)
        let maxLen = max(leftLines.count, rightLines.count)
        diffLines = (0..<maxLen).map { i in
            let l = i < leftLines.count ? leftLines[i] : ""
            let r = i < rightLines.count ? rightLines[i] : ""

            if i >= leftLines.count {
                return (DiffEditorLine(number: nil, text: "", type: .empty),
                        DiffEditorLine(number: i + 1, text: r, type: .added))
            }
            if i >= rightLines.count {
                return (DiffEditorLine(number: i + 1, text: l, type: .removed),
                        DiffEditorLine(number: nil, text: "", type: .empty))
            }
            if l == r {
                return (DiffEditorLine(number: i + 1, text: l, type: .same),
                        DiffEditorLine(number: i + 1, text: r, type: .same))
            }
            return (DiffEditorLine(number: i + 1, text: l, type: .removed),
                    DiffEditorLine(number: i + 1, text: r, type: .added))
        }
    }
}
