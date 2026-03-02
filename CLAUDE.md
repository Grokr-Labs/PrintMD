# PrintMD Technical Guardrails

Technical rules, patterns, and conventions for PrintMD development.

## Code Quality Standards

### Swift Style

**Formatting:**
- Use SwiftLint for linting (see `.swiftlint.yml`)
- Maximum 120 characters per line
- 2-space indentation (or 4 spaces if you prefer - be consistent)
- No trailing whitespace

**Naming Conventions:**
- Classes/Structs: `PascalCase` (e.g., `PDFConverter`, `MarkdownBuilder`)
- Functions/Variables: `camelCase` (e.g., `convertPDF()`, `imageExtractor`)
- Constants: `UPPER_CASE` or `camelCase` (Apple convention: `camelCase` is fine)
- Private members: prefix with `_` or use `private` keyword

**Complexity Limits:**
- Max 150 lines per function (prefer < 100)
- Cyclomatic complexity < 10
- Max 5 parameters (use structs for > 5)

### Testing

**Requirements:**
- New features: XCTest unit tests required
- Bug fixes: Add regression test
- Refactors: Existing tests must pass
- Target coverage: > 75% for core engine, > 50% for UI

**Test Organization:**
```
PrintMD/
├── Sources/
│   ├── PrintMDCore/     (business logic)
│   └── PrintMDUI/       (AppKit UI)
└── Tests/
    ├── CoreTests/       (unit tests)
    └── IntegrationTests/ (end-to-end)
```

### Documentation

**Required Documentation:**
- Top-level classes/structs: Doc comments (`///`)
- Public functions: Doc comments with parameters and return values
- Complex algorithms: Inline comments explaining "why"
- Architecture decisions: Document in code comments or ARCHITECTURE.md

**Example:**
```swift
/// Converts a PDF to Markdown format with image extraction.
/// - Parameters:
///   - pdfData: The PDF file data to convert
///   - outputFolder: Destination folder for images
/// - Returns: Markdown string with embedded image references
/// - Throws: `PDFConversionError` if conversion fails
func convertPDFToMarkdown(
    pdfData: Data,
    outputFolder: URL
) throws -> String {
    // implementation
}
```

### No Commented Code

Delete it. Period. If you need it back, git history exists.

## Architecture

### Module Organization

```
PrintMD.xcodeproj/
├── PrintMD/                    # Main app target
│   ├── App/
│   │   ├── PrintMDApp.swift   # Entry point
│   │   └── AppDelegate.swift
│   ├── PrintDriver/            # System extension
│   │   ├── DriverExtension.swift
│   │   └── JobHandler.swift
│   ├── Core/                   # Business logic
│   │   ├── PDFConverter.swift
│   │   ├── MarkdownBuilder.swift
│   │   ├── ImageExtractor.swift
│   │   └── MarkdownParser.swift
│   ├── UI/                     # AppKit UI
│   │   ├── SettingsWindow.swift
│   │   ├── ProgressIndicator.swift
│   │   └── NotificationHandler.swift
│   └── Utilities/
│       ├── FileManager+Extensions.swift
│       └── Logger.swift
├── PrintMDCoreTests/
│   ├── PDFConverterTests.swift
│   ├── MarkdownBuilderTests.swift
│   └── ImageExtractorTests.swift
└── PrintMDUITests/
    └── IntegrationTests.swift
```

### Key Design Patterns

**1. Separation of Concerns**
- Core engine (PDF→MD) independent of UI
- Printer driver extension independent of settings UI
- File I/O isolated in dedicated modules

**2. Error Handling**
- Use Swift `Result` type or `throws`
- Custom error enums with descriptive cases
- Never silently swallow exceptions

```swift
enum PDFConversionError: LocalizedError {
    case invalidPDF
    case unsupportedContent
    case ioError(String)

    var errorDescription: String? {
        switch self {
        case .invalidPDF:
            return "The file is not a valid PDF"
        case .unsupportedContent:
            return "This PDF contains unsupported content"
        case .ioError(let msg):
            return "File I/O error: \(msg)"
        }
    }
}
```

**3. Async/Concurrency**
- Use Swift Concurrency (async/await) for long operations
- Print driver callbacks: dispatch to background queues
- UI updates: always on main thread
- No DispatchGroup or GCD unless necessary

**4. File Operations**
- Always use `FileManager` with proper error handling
- Atomic writes: write to temp file, then move
- Never delete without backup confirmation
- Clear temp files on app exit

### Dependencies

**Policy:** Minimal external dependencies. Prefer built-in frameworks.

**Approved:**
- PDFKit (macOS built-in)
- AppKit (macOS built-in)
- Foundation (built-in)

**Evaluate before adding:**
- License compatibility (MIT/Apache/BSD preferred; GPL requires exception approval)
- Binary size impact (avoid if > 5MB)
- Maintenance status (active projects only)
- SwiftPM availability

**Forbidden:**
- Objective-C runtime hacks
- Unsafe memory operations (unless absolutely necessary with code review)
- Global state (singletons require justification)

## Build & Deployment

### Xcode Project Structure

**Targets:**
1. `PrintMD` — Main app + system extension
2. `PrintMDTests` — Unit tests
3. `PrintMDUITests` — Integration tests

**Build Settings:**
- Minimum OS: macOS 14.0
- Deployment target: macOS 14.0
- Architectures: arm64 (Apple Silicon)
- Intel support: Evaluate during Phase 2

### Code Signing

**Development:**
- Automatic code signing (Xcode managed)
- Development team: [Your Team ID]

**Release:**
- Manual code signing with distribution certificate
- Notarization required for distribution
- See [NOTARIZATION.md](NOTARIZATION.md) for detailed process

### Build Pipeline

**Local build:**
```bash
xcodebuild -project PrintMD.xcodeproj \
  -scheme PrintMD \
  -configuration Release \
  -arch arm64
```

**Run tests:**
```bash
xcodebuild test \
  -project PrintMD.xcodeproj \
  -scheme PrintMD \
  -destination 'platform=macOS'
```

**SwiftLint:**
```bash
swiftlint lint --strict Sources/ Tests/
```

## Git Workflow

### Branches

**Main branch:** `main` (always release-ready)
- Branch protection: 1 approval required
- CI must pass before merge
- Squash merge to main

**Feature branches:**
```
feature/add-table-support
feature/improve-image-extraction
bugfix/handle-corrupted-pdfs
chore/update-dependencies
```

### Commits

**Format:**
```
type(scope): subject

Optional body explaining the "why".

Fixes #123
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code restructure
- `test:` Test additions
- `chore:` Dependencies, config
- `docs:` Documentation
- `perf:` Performance improvement

**Examples:**
```
feat(converter): add table detection for Markdown output

- Implements heuristic-based table detection
- Handles row/column alignment
- Adds PDFTableParser utility

feat(ui): add progress indicator during conversion
fix(images): prevent duplicate image extraction
refactor(core): split PDFConverter into smaller modules
test: add comprehensive PDF parsing tests
```

## Debugging

### Logging

Use `print()` for debug builds, `os.log` for production:

```swift
import os.log

let logger = Logger(subsystem: "com.grokr-labs.printmd", category: "converter")

logger.debug("Starting PDF conversion")
logger.error("Conversion failed: \(error.localizedDescription)")
```

### Common Issues

**Printer driver not appearing in Print dialog:**
- Check system extension status: `systemextensionsctl list`
- Verify code signing
- Reboot (sometimes required for system extension registration)

**PDF not being captured:**
- Check CUPS log: `/var/log/cups/error_log`
- Verify printer driver filter configuration

**Images not extracting:**
- Check file permissions on output folder
- Verify PDF actually contains embedded images (not scanned PDFs)
- Check disk space availability

## Performance

**Profiling:**
- Use Xcode Instruments (Product > Profile)
- Focus on:
  - Memory usage (avoid leaks during PDF processing)
  - CPU time (conversion should not spike > 80%)
  - Disk I/O (batch writes when possible)

**Optimization principles:**
1. Measure first (profile with real PDFs)
2. Identify bottleneck (PDF parsing? Image extraction? MD generation?)
3. Optimize specifically (don't guess)
4. Test before/after with large documents

## Security

### Code Review Checklist

- [ ] No hardcoded credentials or secrets
- [ ] File paths validated (prevent directory traversal)
- [ ] User input sanitized (filenames, folder paths)
- [ ] Temporary files cleaned up
- [ ] No unintended data leaks to console/logs
- [ ] Code signing and entitlements correct

### System Extension Safety

- Request minimal permissions (principle of least privilege)
- Document all entitlements in SPEC.md
- Notarize before distribution (Apple scan)
- Don't bypass sandbox restrictions without justification

## Continuous Integration

All commits to `main` trigger:
1. ✅ Swift lint (SwiftLint)
2. ✅ Unit tests (XCTest)
3. ✅ Integration tests
4. ✅ Code coverage report

All PRs require CI to pass before merge.

## AI-Assisted Development

We welcome AI assistance! Whether you use Claude Code, GitHub Copilot, or Xcode Copilot:

- ✅ Verify all generated code before committing
- ✅ Understand what the code does
- ✅ Run tests to confirm functionality
- ✅ Follow CLAUDE.md patterns (naming, structure, error handling)
- ℹ️ Optional: mention in PR if helpful context for reviewers

## When In Doubt

1. Check existing code (follow established patterns)
2. Ask in a GitHub Discussion
3. Open an Issue with design questions
4. Create a Draft PR for early feedback

---

**Last Updated:** 2026-03-02
