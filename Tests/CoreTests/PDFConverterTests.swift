import XCTest
import PDFKit
@testable import PrintMDCore

final class PDFConverterTests: XCTestCase {
    var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("printmd-tests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    /// Test that invalid PDF data throws error.
    func testInvalidPDFThrowsError() throws {
        let invalidData = Data("not a pdf".utf8)

        XCTAssertThrowsError(
            try PDFConverter(pdfData: invalidData, outputFolder: tempDirectory)
        ) { error in
            guard case PDFConversionError.invalidPDF = error else {
                return XCTFail("Expected invalidPDF error, got \(error)")
            }
        }
    }

    /// Test that converter initializes with valid PDF.
    func testConverterInitializesWithValidPDF() throws {
        // Create a simple valid PDF
        guard let pdfData = createTestPDF(pages: 1) else {
            XCTFail("Failed to create test PDF")
            return
        }

        let converter = try PDFConverter(pdfData: pdfData, outputFolder: tempDirectory)
        XCTAssertEqual(converter.pageCount, 1)
        XCTAssertFalse(converter.title.isEmpty)
    }

    /// Test that conversion produces non-empty Markdown.
    func testConversionProducesMarkdown() throws {
        guard let pdfData = createTestPDF(pages: 1, text: "# Test Heading") else {
            XCTFail("Failed to create test PDF")
            return
        }

        let converter = try PDFConverter(pdfData: pdfData, outputFolder: tempDirectory)
        let markdown = try converter.convertToMarkdown()

        XCTAssertFalse(markdown.isEmpty)
    }

    /// Test page count accuracy.
    func testPageCount() throws {
        guard let pdfData = createTestPDF(pages: 5) else {
            XCTFail("Failed to create test PDF")
            return
        }

        let converter = try PDFConverter(pdfData: pdfData, outputFolder: tempDirectory)
        XCTAssertEqual(converter.pageCount, 5)
    }

    // MARK: - Helper Methods

    /// Create a simple test PDF with specified page count.
    private func createTestPDF(pages: Int, text: String = "Test content") -> Data? {
        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!

        var mediaBox = CGRect(x: 0, y: 0, width: 612, height: 792)
        guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil) else {
            return nil
        }

        for _ in 0..<pages {
            pdfContext.beginPage(mediaBox: &mediaBox)

            // Draw text
            if let font = CTFontCreateWithName("Helvetica" as CFString, 12, nil) as CTFont? {
                let attrString = NSAttributedString(
                    string: text,
                    attributes: [.font: font]
                )
                let line = CTLineCreateWithAttributedString(attrString as CFAttributedString)
                pdfContext.textPosition = CGPoint(x: 50, y: 750)
                CTLineDraw(line, pdfContext)
            }

            pdfContext.endPage()
        }

        pdfContext.closePDF()
        return pdfData as Data
    }
}
