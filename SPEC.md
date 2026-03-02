# PrintMD Specification

## Vision

PrintMD is a native macOS printer driver that seamlessly converts any printable document into clean Markdown format. Users should be able to "print to Markdown" as easily as they print to PDF, with zero configuration required beyond initial installation.

## Core Requirements

### Functional Requirements

**FR-1: Printer Driver Integration**
- Appear in macOS Print dialog as "PrintMD" printer
- Accept print jobs from any application that supports printing
- Integrate with Print & Scan system preferences (automatic recognition)

**FR-2: PDF Conversion**
- Convert incoming PDF (from print jobs) to Markdown format
- Preserve document structure:
  - Headings (hierarchical levels)
  - Lists (ordered, unordered, nested)
  - Tables (full fidelity)
  - Images (extract and embed)
  - Bold, italic, code formatting
  - Links and references

**FR-3: Image Handling**
- Automatically extract images from PDF
- Save to `{filename}-images/` folder alongside Markdown file
- Embed image references in Markdown using relative paths
- Support common formats (PNG, JPEG, GIF, WebP, SVG)
- Preserve image quality (no unnecessary recompression)

**FR-4: User Interface**
- Print dialog integration (destination folder + filename selection)
- Progress indicator (conversion in progress)
- Completion notification (file saved, ready to use)
- Settings panel (optional: compression level, image quality, etc.)

**FR-5: File Output**
- User selects destination folder (or default: ~/Documents/PrintMD/)
- User specifies filename (or use document title)
- Output: `filename.md` + `filename-images/` folder
- Atomic operations (fail safely, no partial files on error)

### Non-Functional Requirements

**NFR-1: Performance**
- Conversion < 10 seconds for typical multi-page document (on Apple Silicon M1+)
- No UI freezing during conversion
- Efficient memory usage (handle large documents, 50+ pages)

**NFR-2: Reliability**
- No crashes on edge cases (malformed PDFs, unusual fonts, etc.)
- Graceful error handling with user-friendly messages
- Atomic file operations (don't leave partial files)

**NFR-3: Security**
- No data sent to cloud services
- All processing local and private
- Standard macOS code signing and notarization
- Compliant with App Store security requirements (future)

**NFR-4: Compatibility**
- macOS 14 (Sonoma) and later
- Apple Silicon (M-series chips)
- Support Intel Macs only if performance/maintainability impact is negligible (evaluate during development)

## Architecture Overview

```
Print Job (from any app)
         ↓
    CUPS System
         ↓
PrintMD Printer Driver Extension
         ↓
         ├─ Receive PDF
         ├─ Extract metadata (title, author, etc.)
         └─→ Core Conversion Engine
              ├─ PDF → Text/Markdown extraction
              ├─ Image detection and extraction
              ├─ Structure analysis (headings, lists, tables)
              └─→ Markdown Generator
                   ├─ Assemble formatted content
                   ├─ Embed image references
                   └─→ Output Handler
                        ├─ Write .md file
                        ├─ Save images folder
                        └─→ User Notification
```

## Technology Stack

- **Language:** Swift 5.9+ (with Objective-C bridging where needed)
- **macOS APIs:**
  - System Extensions (for printer driver)
  - PDFKit (PDF parsing)
  - AppKit (UI, File dialogs)
- **Dependencies:** TBD (evaluate during implementation)
  - PDF extraction: PDFKit or third-party library (check licensing)
  - Markdown generation: custom builder or existing library
  - Image processing: Vision framework or ImageIO

## Implementation Phases

### Phase 1: Foundation (Current)
- [x] Project initialization and governance
- [ ] Printer driver system extension skeleton
- [ ] PDF capture and routing
- [ ] Basic MD generation (text extraction)
- [ ] File output system

### Phase 2: Enhancement
- [ ] Full Markdown structure preservation (headings, lists, tables)
- [ ] Image extraction and embedding
- [ ] Settings UI (output preferences, compression, etc.)
- [ ] Progress indicators and notifications

### Phase 3: Polish
- [ ] Code signing and notarization
- [ ] Edge case handling and robustness
- [ ] Performance optimization
- [ ] User documentation and help

### Phase 4: Multi-Platform (Roadmap)
- [ ] iOS/iPadOS support
- [ ] visionOS support
- [ ] App Store submission

## Open Questions & Research

1. **PDF Extraction Library:** What's the best way to extract structured content from PDFs in Swift?
   - PDFKit (built-in but limited)
   - Third-party: pdfium, poppler, etc.
   - OCR for scanned PDFs (future enhancement?)

2. **Table Detection:** How to reliably identify and preserve table structure?
   - PDF layout analysis
   - Heuristic-based detection vs. ML models

3. **Code Signing:** What's required for App Store distribution of printer drivers?
   - System Extension entitlements
   - Notarization requirements
   - Sandbox exceptions

4. **Intel Mac Support:** Is it worth maintaining Intel compatibility?
   - Survey user demand during beta
   - Consider maintenance burden vs. reward

## Success Criteria

✅ User can print document → instantly get clean Markdown with images
✅ Zero user configuration beyond initial installation
✅ Handles real-world documents (web articles, PDFs, emails, etc.)
✅ Preserves formatting (headings, lists, tables, emphasis)
✅ Images embedded with correct relative paths
✅ Production-ready (stable, well-tested)
✅ App Store approval path clear

## References

- [macOS Printer Driver Development](https://developer.apple.com/documentation/system_extensions)
- [PDFKit Documentation](https://developer.apple.com/documentation/pdfkit)
- [CUPS Standard](https://www.cups.org/doc/spec-ipp.html)
- [Markdown Specification](https://spec.commonmark.org/)
