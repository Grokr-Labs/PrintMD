# PrintMD

**Print to Markdown** — A native macOS printer driver that converts any document directly to Markdown format.

## Overview

PrintMD adds a "Print to Markdown" printer to your macOS Print dialog, just like "Print to PDF." Select any document, choose PrintMD as your printer, and instantly get a clean Markdown file with extracted images in a companion folder.

**Current Status:** Production-ready macOS 14+ implementation (Apple Silicon)
**Roadmap:** iOS/iPadOS support → visionOS support → App Store distribution

## Features

- ✅ Native macOS printer driver (no scripts, no workarounds)
- ✅ Converts printed documents to Markdown with proper formatting
- ✅ Automatic image extraction and embedding
- ✅ Works from any app that supports printing (Safari, Preview, Word, etc.)
- ✅ Simple UI/UX: select printer → choose destination → done
- ✅ Preserves document structure (headings, lists, tables, etc.)
- ✅ Multi-platform roadmap (iOS/iPadOS/visionOS)

## System Requirements

- **macOS 14** (Sonoma) or later
- **Apple Silicon** (M1, M2, M3, M4, etc.)
- ~50 MB disk space

## Installation

### From Source (Development)

```bash
git clone https://github.com/Grokr-Labs/PrintMD.git
cd PrintMD
open PrintMD.xcodeproj

# In Xcode:
# 1. Select PrintMD target
# 2. Build: Product > Build (⌘B)
# 3. Run: Product > Run (⌘R)
# 4. Printer driver installs automatically
```

### From Releases (End User)

[Download latest release](../../releases)

## Usage

### Basic Workflow

1. Open any document (webpage, PDF, email, etc.)
2. Go to **File > Print** (or ⌘P)
3. Select **PrintMD** from the printer dropdown
4. Choose output folder and filename
5. Click **Print**

PrintMD will:
- Create `document.md` with formatted Markdown content
- Extract images to `document-images/` folder
- Automatically embed image references in the Markdown file

### Example Output

```markdown
# Article Title

The main content here...

![Embedded image](document-images/image-1.png)

## Sections are preserved

Lists work too:
- Item 1
- Item 2

| Tables | Are | Supported |
|--------|-----|-----------|
| Row 1  | Data| Here      |
```

## Architecture

PrintMD consists of:

- **Printer Driver Extension** — System extension that intercepts print jobs
- **Core Engine** — Converts PDF → Markdown with image extraction
- **User Interface** — Print dialog integration + settings

For technical details, see [SPEC.md](SPEC.md) and [CLAUDE.md](CLAUDE.md).

## Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup
- Code guidelines
- Contribution workflow
- AI-assisted development policy

## License

MIT License — see [LICENSE](LICENSE) file.

## Contact & Sponsorship

- **GitHub Issues:** [Report bugs or request features](../../issues)
- **Discussions:** [Community Q&A](../../discussions)
- **Sponsor:** [Support development](https://github.com/sponsors/JonathanWorks)

---

**Made with ❤️ by [Jonathan Works](https://github.com/JonathanWorks) and contributors**
