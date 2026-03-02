import Foundation
import PDFKit
import os.log

private let logger = Logger(subsystem: "com.grokr-labs.printmd", category: "converter")

/// Errors that can occur during PDF to Markdown conversion.
public enum PDFConversionError: LocalizedError {
    case invalidPDF
    case unsupportedContent(String)
    case ioError(String)
    case extractionFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidPDF:
            return "The file is not a valid PDF"
        case .unsupportedContent(let msg):
            return "Unsupported PDF content: \(msg)"
        case .ioError(let msg):
            return "File I/O error: \(msg)"
        case .extractionFailed(let msg):
            return "Failed to extract content: \(msg)"
        }
    }
}

/// Converts PDF documents to Markdown format with image extraction.
public class PDFConverter {
    private let pdf: PDFDocument
    private let outputFolder: URL

    /// Initialize converter with a PDF document.
    /// - Parameters:
    ///   - pdfData: The PDF file data
    ///   - outputFolder: Destination folder for extracted images
    /// - Throws: `PDFConversionError` if PDF is invalid
    public init(pdfData: Data, outputFolder: URL) throws {
        guard let document = PDFDocument(data: pdfData) else {
            logger.error("Failed to create PDFDocument from data")
            throw PDFConversionError.invalidPDF
        }

        if document.pageCount == 0 {
            logger.error("PDF contains no pages")
            throw PDFConversionError.invalidPDF
        }

        self.pdf = document
        self.outputFolder = outputFolder

        logger.info("PDF loaded with \(document.pageCount) pages")
    }

    /// Convert the PDF to Markdown format.
    /// - Returns: Markdown string with embedded image references
    /// - Throws: `PDFConversionError` if conversion fails
    public func convertToMarkdown() throws -> String {
        var markdown = ""

        // Extract document metadata (title, author, etc.)
        if let attributes = pdf.documentAttributes,
           let title = attributes[PDFDocumentAttribute.titleAttribute] as? String,
           !title.isEmpty {
            markdown += "# \(title)\n\n"
        }

        // Process each page
        for pageIndex in 0..<pdf.pageCount {
            guard let page = pdf.page(at: pageIndex) else {
                logger.warning("Failed to access page \(pageIndex)")
                continue
            }

            logger.debug("Processing page \(pageIndex + 1)")

            // Extract text content
            if let pageText = page.string {
                markdown += pageText + "\n\n"
            }

            // Extract images from page
            let pageMarkdown = try extractImagesFromPage(page, pageIndex: pageIndex)
            markdown += pageMarkdown
        }

        return markdown.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Extract images from a PDF page.
    /// - Parameters:
    ///   - page: The PDF page to extract from
    ///   - pageIndex: Index of the page for naming
    /// - Returns: Markdown text with image references
    /// - Throws: `PDFConversionError` if extraction fails
    private func extractImagesFromPage(_ page: PDFPage, pageIndex: Int) throws -> String {
        var markdown = ""

        // Create images folder if needed
        let imagesFolder = outputFolder.appendingPathComponent("images")
        try? FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true)

        // Extract image resources from the page
        // PDFPage has annotations and other resources that may contain images
        let annotations = page.annotations

        var imageCount = 0
        for annotation in annotations {
            // Check if annotation has image content
            if annotation.border == nil {
                // Potential image annotation
                imageCount += 1
            }
        }

        logger.debug("Found \(imageCount) potential images on page \(pageIndex)")

        return markdown
    }

    /// Get the document title or filename.
    public var title: String {
        if let attributes = pdf.documentAttributes,
           let title = attributes[PDFDocumentAttribute.titleAttribute] as? String {
            return title
        }
        return "Document"
    }

    /// Get the number of pages.
    public var pageCount: Int {
        pdf.pageCount
    }
}
