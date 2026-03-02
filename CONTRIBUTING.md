# Contributing to PrintMD

Welcome! We're building a native macOS printer driver that converts documents to Markdown. We embrace contributions from developers at all levels — and we welcome AI-assisted development!

## Before You Start

1. **Read the project docs:**
   - [`SPEC.md`](SPEC.md) — What we're building and why
   - [`CLAUDE.md`](CLAUDE.md) — Technical guardrails and Swift conventions
   - [`README.md`](README.md) — Quick overview and usage

2. **Check existing work:**
   - Browse [Issues](../../issues) for related discussions
   - Check [Pull Requests](../../pulls) to avoid duplicate work

3. **For significant changes:**
   - Open an Issue first to discuss approach
   - Wait for maintainer feedback before coding
   - This saves everyone time!

## 🤖 AI-Assisted Development

We love AI tools! Claude Code, GitHub Copilot, Cursor, and similar productivity tools are fantastic for Swift development.

**What we care about:**
- ✅ Code works correctly (tests pass)
- ✅ Follows `CLAUDE.md` guardrails (Swift style, architecture)
- ✅ You understand what the code does
- ✅ You can explain the implementation
- ✅ Tests cover new functionality

**What we don't care about:**
- ❌ Whether AI wrote it
- ❌ What percentage is AI-generated
- ❌ Which tool you used

**Optional disclosure:** If you want to share your workflow (helps other contributors learn!), mention it in the PR description.

## Development Workflow

### 1. Fork & Clone

```bash
# Fork via GitHub UI
git clone https://github.com/YOUR-USERNAME/PrintMD.git
cd PrintMD
```

### 2. Create Branch

```bash
git checkout -b feature/your-feature-name
# OR
git checkout -b bugfix/issue-123
```

### 3. Set Up Development Environment

**Requirements:**
- macOS 14 (Sonoma) or later
- Xcode 15+
- Apple Silicon Mac (M1, M2, M3, etc.)

**Open project:**
```bash
open PrintMD.xcodeproj
```

**Install linting:**
```bash
brew install swiftlint
```

### 4. Make Changes

Follow rules in [`CLAUDE.md`](CLAUDE.md):
- Respect Swift naming conventions
- Follow code style (SwiftLint will enforce)
- Keep functions under 150 lines
- Write doc comments for public APIs
- Update tests

### 5. Test Locally

**Build the project:**
```bash
# In Xcode: Product > Build (⌘B)
# Or via command line:
xcodebuild -scheme PrintMD -configuration Debug
```

**Run all tests:**
```bash
# In Xcode: Product > Test (⌘U)
# Or via command line:
xcodebuild test -scheme PrintMD -destination 'platform=macOS'
```

**Lint code:**
```bash
swiftlint lint --strict Sources/ Tests/
```

**All checks must pass before opening PR.**

### 6. Commit & Push

```bash
git add .
git commit -m "feat(converter): improve PDF table detection

- Adds heuristic-based table detection
- Handles complex nested tables
- Improves Markdown output fidelity

Fixes #123"

git push origin feature/your-feature-name
```

**Commit message format:**
- `feat:` — New feature
- `fix:` — Bug fix
- `refactor:` — Code restructure (no behavior change)
- `test:` — Test additions/changes
- `chore:` — Dependencies, build config
- `docs:` — Documentation updates
- `perf:` — Performance improvements

### 7. Open Pull Request

Fill out the PR template completely:
- Link related issues
- Describe what changed and why
- Show testing evidence (screenshots, terminal output)
- Mention if AI-assisted (optional)

### 8. Code Review

- Respond to feedback promptly
- Ask questions if unclear
- Push new commits to same branch
- Resolve all review conversations
- Wait for ✅ approval + CI passing

### 9. Merge

Maintainer will merge when:
- ✅ CI passes (lint, tests, coverage)
- ✅ 1 approval received
- ✅ All conversations resolved
- ✅ Code quality meets standards

## Code Quality Standards

### Size Guidelines

- **Ideal PR:** 50-200 lines changed
- **Maximum:** 400 lines changed
- **If larger:** Split into multiple PRs

### Testing Requirements

- **New features:** Must include XCTest unit tests
- **Bug fixes:** Add regression test
- **Refactors:** Existing tests must pass
- **Target coverage:** > 75% for core logic, > 50% for UI

### Swift Style

- Max 120 characters per line
- 2-space indentation
- `PascalCase` for types, `camelCase` for functions/variables
- Doc comments on public APIs (use `///`)
- No commented-out code (delete it, use git history if needed)

### Documentation

- Update README if user-facing changes
- Update SPEC.md if requirements change
- Comment complex logic (not obvious code)
- Add doc comments to public functions

## Common Tasks

### Adding a New Feature

1. Open Issue: "feat: describe your feature"
2. Get feedback from maintainer
3. Implement with tests
4. Open PR linking the Issue
5. Iterate based on review

### Fixing a Bug

1. Open Issue: "bug: describe the problem and reproduction steps"
2. Create branch: `bugfix/issue-number`
3. Add regression test that currently fails
4. Fix the bug (test should now pass)
5. Open PR linking the Issue

### Improving Performance

1. Profile with Xcode Instruments (Product > Profile)
2. Identify bottleneck
3. Implement optimization
4. Measure improvement
5. Add performance tests
6. Document changes in PR

## Troubleshooting

### Printer driver not loading

```bash
# Check system extension status
systemextensionsctl list

# Check CUPS logs
log stream --predicate 'process == "cupsd"' --level debug
```

### Build failures

- Ensure Xcode is up to date: `xcode-select --install`
- Clean build folder: ⌘⇧K in Xcode
- Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### Test failures

- Run single test: Click diamond icon next to test in Xcode
- View test output: Product > Test Results (⌘9)
- Debug test: Set breakpoint and run (⌘U)

### SwiftLint issues

```bash
# See all issues
swiftlint lint Sources/ Tests/

# Autocorrect what it can
swiftlint --fix
```

## Recognition

Contributors are:
- Listed in README (after first merged PR)
- Credited in release notes
- Eligible for collaborator status (after 3-5 quality PRs)

## Questions?

- **General questions:** [Open a Discussion](../../discussions)
- **Bug reports:** [Open an Issue](../../issues)
- **Feature ideas:** [Open an Issue](../../issues) with `enhancement` label
- **PR questions:** Comment directly on the PR
- **Architecture questions:** Open Issue with `architecture` label

## Code of Conduct

Be respectful. No harassment, discrimination, or abuse. Report issues to [@JonathanWorks](https://github.com/JonathanWorks).

---

**Thank you for contributing! 🎉**

We're excited to build PrintMD together. Questions? Don't hesitate to ask!
