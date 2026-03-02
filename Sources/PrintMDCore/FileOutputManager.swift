import Foundation
import os.log

private let logger = Logger(subsystem: "com.grokr-labs.printmd", category: "fileio")

/// Errors that can occur during file I/O operations.
public enum FileOutputError: LocalizedError {
    case invalidPath(String)
    case permissionDenied(String)
    case diskFull(String)
    case alreadyExists(String)
    case writeFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidPath(let msg):
            return "Invalid file path: \(msg)"
        case .permissionDenied(let msg):
            return "Permission denied: \(msg)"
        case .diskFull(let msg):
            return "Disk full: \(msg)"
        case .alreadyExists(let msg):
            return "File already exists: \(msg)"
        case .writeFailed(let msg):
            return "Write failed: \(msg)"
        }
    }
}

/// Manages file output operations for converted Markdown documents.
public class FileOutputManager {
    private let fileManager = FileManager.default

    /// Write Markdown content to a file.
    /// - Parameters:
    ///   - markdown: The Markdown content
    ///   - filename: Name of the output file (without .md extension)
    ///   - folderURL: Destination folder
    /// - Returns: URL of the written file
    /// - Throws: `FileOutputError` if write fails
    public func writeMarkdownFile(
        _ markdown: String,
        filename: String,
        to folderURL: URL
    ) throws -> URL {
        // Validate path
        guard !filename.isEmpty else {
            throw FileOutputError.invalidPath("Filename cannot be empty")
        }

        // Clean filename (remove invalid characters)
        let cleanFilename = sanitizeFilename(filename)

        // Create markdown file URL
        let markdownURL = folderURL.appendingPathComponent("\(cleanFilename).md")

        // Check if file already exists
        if fileManager.fileExists(atPath: markdownURL.path) {
            logger.warning("File already exists: \(cleanFilename).md")
            throw FileOutputError.alreadyExists(markdownURL.path)
        }

        // Write to temporary file first (atomic operation)
        let tempURL = folderURL.appendingPathComponent(".\(cleanFilename).tmp")

        do {
            try markdown.write(to: tempURL, atomically: true, encoding: .utf8)
            logger.debug("Wrote temporary file: \(tempURL.lastPathComponent)")

            // Move temp file to final location
            try fileManager.moveItem(at: tempURL, to: markdownURL)
            logger.info("Markdown file written: \(markdownURL.lastPathComponent)")

            return markdownURL
        } catch {
            // Clean up temp file
            try? fileManager.removeItem(at: tempURL)

            if fileManager.fileExists(atPath: folderURL.path) == false {
                throw FileOutputError.invalidPath("Destination folder does not exist")
            }

            throw FileOutputError.writeFailed(error.localizedDescription)
        }
    }

    /// Create output directory if it doesn't exist.
    /// - Parameters:
    ///   - folderURL: Path to create
    /// - Throws: `FileOutputError` if creation fails
    public func ensureOutputFolder(_ folderURL: URL) throws {
        if fileManager.fileExists(atPath: folderURL.path) {
            // Verify it's a directory
            var isDir: ObjCBool = false
            guard fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDir), isDir.boolValue else {
                throw FileOutputError.invalidPath("Path exists but is not a directory")
            }
            return
        }

        do {
            try fileManager.createDirectory(
                at: folderURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
            logger.info("Created output folder: \(folderURL.lastPathComponent)")
        } catch {
            throw FileOutputError.writeFailed("Failed to create folder: \(error.localizedDescription)")
        }
    }

    /// Delete file at URL.
    /// - Parameters:
    ///   - fileURL: URL of file to delete
    /// - Throws: `FileOutputError` if deletion fails
    public func deleteFile(_ fileURL: URL) throws {
        do {
            try fileManager.removeItem(at: fileURL)
            logger.debug("Deleted file: \(fileURL.lastPathComponent)")
        } catch {
            throw FileOutputError.writeFailed("Failed to delete file: \(error.localizedDescription)")
        }
    }

    /// Check available disk space in folder.
    /// - Parameters:
    ///   - folderURL: Folder to check
    /// - Returns: Available space in bytes
    public func availableDiskSpace(for folderURL: URL) -> Int64 {
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: folderURL.path)
            if let availableSpace = attributes[.systemFreeSize] as? Int64 {
                return availableSpace
            }
        } catch {
            logger.error("Failed to check disk space: \(error.localizedDescription)")
        }
        return 0
    }

    /// Sanitize filename to remove invalid characters.
    private func sanitizeFilename(_ filename: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?*|\"<>")
        let components = filename.components(separatedBy: invalidCharacters)
        let sanitized = components.joined(separator: "-")
        return sanitized.isEmpty ? "document" : sanitized
    }

    /// Check if output folder has write permissions.
    /// - Parameters:
    ///   - folderURL: Folder to check
    /// - Returns: true if writable
    public func isWritable(_ folderURL: URL) -> Bool {
        fileManager.isWritableFile(atPath: folderURL.path)
    }
}
