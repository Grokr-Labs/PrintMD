import Foundation
import os.log

private let logger = Logger(subsystem: "com.grokr-labs.printmd", category: "markdown")

/// Structured representation of Markdown document elements.
public enum MarkdownElement {
    case heading(level: Int, text: String)
    case paragraph(text: String)
    case listItem(text: String, level: Int)
    case table(rows: [[String]])
    case image(url: String, alt: String)
    case codeBlock(language: String, code: String)
    case link(text: String, url: String)
    case emphasis(text: String, style: EmphasisStyle)

    public enum EmphasisStyle {
        case bold
        case italic
        case code
    }
}

/// Builds well-formed Markdown documents from structured elements.
public class MarkdownBuilder {
    private var elements: [MarkdownElement] = []
    private var imageCount = 0

    /// Initialize a new Markdown builder.
    public init() {}

    /// Add a heading to the document.
    /// - Parameters:
    ///   - level: Heading level (1-6)
    ///   - text: Heading text
    public func addHeading(_ text: String, level: Int = 1) {
        let validLevel = max(1, min(6, level))
        elements.append(.heading(level: validLevel, text: text))
        logger.debug("Added heading level \(validLevel)")
    }

    /// Add a paragraph.
    public func addParagraph(_ text: String) {
        elements.append(.paragraph(text: text))
    }

    /// Add a list item with optional nesting level.
    public func addListItem(_ text: String, level: Int = 0) {
        let validLevel = max(0, level)
        elements.append(.listItem(text: text, level: validLevel))
    }

    /// Add a table.
    /// - Parameters:
    ///   - rows: Array of rows, each containing cell strings
    public func addTable(rows: [[String]]) {
        guard !rows.isEmpty else {
            logger.warning("Attempted to add empty table")
            return
        }
        elements.append(.table(rows: rows))
        logger.debug("Added table with \(rows.count) rows")
    }

    /// Add an image with relative path.
    /// - Parameters:
    ///   - imagePath: Relative path to image file
    ///   - alt: Alt text for accessibility
    public func addImage(path: String, alt: String) {
        elements.append(.image(url: path, alt: alt))
        imageCount += 1
    }

    /// Add a code block.
    /// - Parameters:
    ///   - code: Source code
    ///   - language: Programming language for syntax highlighting
    public func addCodeBlock(_ code: String, language: String = "plaintext") {
        elements.append(.codeBlock(language: language, code: code))
    }

    /// Add inline emphasis.
    public func addEmphasis(_ text: String, style: MarkdownElement.EmphasisStyle) {
        elements.append(.emphasis(text: text, style: style))
    }

    /// Add a hyperlink.
    public func addLink(text: String, url: String) {
        elements.append(.link(text: text, url: url))
    }

    /// Generate the final Markdown string.
    /// - Returns: Formatted Markdown document
    public func build() -> String {
        var markdown = ""

        for (index, element) in elements.enumerated() {
            markdown += renderElement(element)

            // Add spacing between elements (except after headings)
            if index < elements.count - 1,
               case .heading = element {
                markdown += "\n"
            } else if index < elements.count - 1 {
                markdown += "\n\n"
            }
        }

        return markdown.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Render a single Markdown element.
    private func renderElement(_ element: MarkdownElement) -> String {
        switch element {
        case .heading(let level, let text):
            let hashes = String(repeating: "#", count: level)
            return "\(hashes) \(text)"

        case .paragraph(let text):
            return text

        case .listItem(let text, let level):
            let indent = String(repeating: "  ", count: level)
            return "\(indent)- \(text)"

        case .table(let rows):
            return renderTable(rows)

        case .image(let url, let alt):
            return "![\(alt)](\(url))"

        case .codeBlock(let language, let code):
            return "```\(language)\n\(code)\n```"

        case .link(let text, let url):
            return "[\(text)](\(url))"

        case .emphasis(let text, let style):
            switch style {
            case .bold:
                return "**\(text)**"
            case .italic:
                return "_\(text)_"
            case .code:
                return "`\(text)`"
            }
        }
    }

    /// Render a table in Markdown format.
    private func renderTable(_ rows: [[String]]) -> String {
        guard !rows.isEmpty else { return "" }

        var table = ""

        // Header row
        let headerRow = rows[0]
        table += "| " + headerRow.joined(separator: " | ") + " |\n"

        // Separator row
        let separatorCells = headerRow.map { _ in "---" }
        table += "| " + separatorCells.joined(separator: " | ") + " |\n"

        // Data rows
        for row in rows.dropFirst() {
            table += "| " + row.joined(separator: " | ") + " |\n"
        }

        return table.trimmingCharacters(in: .newlines)
    }

    /// Get count of images added.
    public var addedImageCount: Int {
        imageCount
    }

    /// Clear all elements.
    public func clear() {
        elements.removeAll()
        imageCount = 0
    }
}
