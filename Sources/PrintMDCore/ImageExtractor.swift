import Foundation
import PDFKit
import AppKit
import os.log

private let logger = Logger(subsystem: "com.grokr-labs.printmd", category: "images")

/// Extracts and processes images from PDF documents.
public class ImageExtractor {
    private let outputFolder: URL

    /// Initialize the image extractor.
    /// - Parameters:
    ///   - outputFolder: Destination folder for extracted images
    public init(outputFolder: URL) {
        self.outputFolder = outputFolder
    }

    /// Extract all images from a PDF page.
    /// - Parameters:
    ///   - page: The PDF page to extract from
    ///   - pageIndex: Page index for naming
    /// - Returns: Array of image file URLs and their references
    public func extractImages(from page: PDFPage, pageIndex: Int) -> [(url: URL, reference: String)] {
        var images: [(url: URL, reference: String)] = []

        // Create images subfolder
        let imagesFolder = outputFolder.appendingPathComponent("images")
        do {
            try FileManager.default.createDirectory(
                at: imagesFolder,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            logger.error("Failed to create images folder: \(error.localizedDescription)")
            return images
        }

        // Extract images from page resources
        // PDFKit provides limited image extraction; full implementation would need
        // deeper PDF content stream parsing
        var imageIndex = 0

        // Process page annotations which may contain images
        for annotation in page.annotations {
            if let imageData = extractImageFromAnnotation(annotation, pageIndex: pageIndex, imageIndex: imageIndex) {
                let filename = String(format: "image-%d-%d.png", pageIndex, imageIndex)
                let fileURL = imagesFolder.appendingPathComponent(filename)

                do {
                    try imageData.write(to: fileURL)
                    let reference = "images/\(filename)"
                    images.append((url: fileURL, reference: reference))
                    imageIndex += 1
                    logger.debug("Extracted image: \(filename)")
                } catch {
                    logger.error("Failed to save image: \(error.localizedDescription)")
                }
            }
        }

        return images
    }

    /// Extract image data from a PDF annotation.
    /// - Parameters:
    ///   - annotation: The PDF annotation
    ///   - pageIndex: Page index for reference
    ///   - imageIndex: Image index for reference
    /// - Returns: Image data if found
    private func extractImageFromAnnotation(_ annotation: PDFAnnotation, pageIndex: Int, imageIndex: Int) -> Data? {
        // Check for common image annotation types
        let annotationType = annotation.type ?? ""

        switch annotationType {
        case PDFAnnotationSubtype.stamp.rawValue,
             PDFAnnotationSubtype.ink.rawValue:
            // May contain image content
            // This is a simplified check; full implementation would parse image XObjects
            return nil

        default:
            return nil
        }
    }

    /// Optimize image for web use.
    /// - Parameters:
    ///   - imageData: Original image data
    ///   - quality: Compression quality (0.0-1.0)
    /// - Returns: Optimized image data
    public static func optimizeImage(_ imageData: Data, quality: CGFloat = 0.85) -> Data? {
        guard let image = NSImage(data: imageData) else {
            logger.error("Failed to load image from data")
            return nil
        }

        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            logger.error("Failed to create bitmap representation")
            return nil
        }

        // Compress to PNG
        guard let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            logger.error("Failed to create PNG representation")
            return imageData  // Return original if optimization fails
        }

        logger.debug("Image optimized: \(imageData.count) -> \(pngData.count) bytes")
        return pngData
    }

    /// Get list of extracted images.
    /// - Returns: URLs of all images in the output folder
    public func listExtractedImages() -> [URL] {
        let imagesFolder = outputFolder.appendingPathComponent("images")

        guard FileManager.default.fileExists(atPath: imagesFolder.path) else {
            return []
        }

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: imagesFolder,
                includingPropertiesForKeys: nil
            )
            return fileURLs.filter { $0.pathExtension.lowercased() == "png" }
        } catch {
            logger.error("Failed to list images: \(error.localizedDescription)")
            return []
        }
    }
}
