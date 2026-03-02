# PrintMD Xcode Project Setup

This document describes the Xcode project structure and how to work with it.

## Project Structure

```
PrintMD.xcodeproj/
├── PrintMD (App Target)
│   ├── Sources/PrintMDApp/
│   │   ├── main.swift
│   │   └── AppDelegate.swift
│   ├── Resources/
│   │   └── Assets.xcassets/
│   └── Info.plist
│
├── PrintMDDriver (System Extension Target)
│   ├── Sources/PrintMDDriver/
│   │   └── DriverExtension.swift
│   └── Info.plist (with SystemExtension entitlements)
│
├── PrintMDCore (Framework Target)
│   ├── Sources/PrintMDCore/
│   │   ├── PDFConverter.swift
│   │   ├── MarkdownBuilder.swift
│   │   ├── ImageExtractor.swift
│   │   └── FileOutputManager.swift
│   └── Info.plist
│
└── Tests/
    ├── CoreTests/
    │   ├── PDFConverterTests.swift
    │   └── FileOutputManagerTests.swift
    └── IntegrationTests/
        └── PrintJobIntegrationTests.swift
```

## Targets

### 1. PrintMD (Executable)
- **Type**: macOS App
- **Language**: Swift
- **Deployment Target**: macOS 14.0+
- **Architecture**: arm64
- **Dependencies**: PrintMDCore, PrintMDDriver

**Responsibility**: Main application entry point, menu bar UI, settings window

### 2. PrintMDDriver (System Extension)
- **Type**: System Extension
- **Deployment Target**: macOS 14.0+
- **Architecture**: arm64
- **Entitlements**: Requires `com.apple.security.system-extension` entitlements
- **Dependencies**: PrintMDCore

**Responsibility**: CUPS printer driver, print job interception, job routing

### 3. PrintMDCore (Framework)
- **Type**: Framework
- **Deployment Target**: macOS 14.0+
- **Architecture**: arm64
- **No External Dependencies** (uses PDFKit, AppKit)

**Responsibility**: PDF→Markdown conversion, image extraction, file I/O

### 4. CoreTests (Test Bundle)
- **Type**: Unit Tests
- **Target Dependencies**: PrintMDCore
- **Coverage**: PDFConverter, MarkdownBuilder, FileOutputManager

### 5. IntegrationTests (Test Bundle)
- **Type**: Integration Tests
- **Target Dependencies**: PrintMD, PrintMDCore
- **Coverage**: End-to-end PDF→Markdown workflow

## Build Phases

### All Targets
1. **Compile Sources** - Swift files
2. **Link Binary with Libraries** - Core frameworks
3. **Copy Bundle Resources** - Assets, Info.plist
4. **Run Script** - SwiftLint (strict mode)

### PrintMDDriver
5. **Code Sign on Copy** - System extension signing requirements

## Info.plist Configuration

### App Target (PrintMD)
```plist
<key>NSMainStoryboardFile</key>
<string>Main</string>

<key>NSPrincipalClass</key>
<string>NSApplication</string>

<key>NSSupportsAutomaticTermination</key>
<true/>

<key>NSRequiresIPhoneOS</key>
<false/>

<key>CFBundleDisplayName</key>
<string>PrintMD</string>

<key>CFBundleIdentifier</key>
<string>com.grokr-labs.printmd</string>

<key>CFBundleVersion</key>
<string>1</string>

<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

### Driver Extension (PrintMDDriver)
```plist
<key>NSExtensionPointIdentifier</key>
<string>com.apple.system-extension.driver</string>

<key>NSExtensionPrincipalClass</key>
<string>$(PRODUCT_MODULE_NAME).DriverExtension</string>

<key>CFBundleIdentifier</key>
<string>com.grokr-labs.printmd.driver</string>

<!-- Entitlements -->
<key>com.apple.security.system-extension</key>
<array>
  <string>com.apple.system-extension.driver</string>
</array>

<key>com.apple.security.cs.disable-library-validation</key>
<true/>
```

## Building from Command Line

```bash
# Build app
xcodebuild -project PrintMD.xcodeproj \
  -scheme PrintMD \
  -configuration Debug \
  -arch arm64

# Run tests
xcodebuild test \
  -project PrintMD.xcodeproj \
  -scheme PrintMD \
  -destination 'platform=macOS,arch=arm64'

# Build for release (with code signing)
xcodebuild -project PrintMD.xcodeproj \
  -scheme PrintMD \
  -configuration Release \
  -arch arm64 \
  CODE_SIGN_IDENTITY="Apple Development"
```

## Code Signing & Entitlements

### Development Signing
- **Team ID**: Your Apple Developer Team ID
- **Signing Certificate**: Apple Development
- **Provisioning Profile**: Automatic (Xcode managed)

### Entitlements Files

**PrintMD.entitlements** (App):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>com.apple.security.app-sandbox</key>
  <false/>
</dict>
</plist>
```

**PrintMDDriver.entitlements** (Extension):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>com.apple.security.system-extension</key>
  <array>
    <string>com.apple.system-extension.driver</string>
  </array>
  <key>com.apple.security.cs.disable-library-validation</key>
  <true/>
</dict>
</plist>
```

## Development Workflow

### Adding a New Feature

1. Create Swift file in appropriate Sources/ directory
2. Add unit tests in Tests/ directory
3. Update target dependencies if adding framework imports
4. Run `xcodebuild test` to verify
5. SwiftLint runs automatically on build

### Testing

```bash
# Run all tests
xcodebuild test -project PrintMD.xcodeproj -scheme PrintMD

# Run specific test
xcodebuild test -project PrintMD.xcodeproj \
  -scheme PrintMD \
  -only-testing CoreTests

# View test results
# - Xcode: Product > Test Results (⌘9)
# - CLI: xcodebuild test ... 2>&1 | grep -A 5 "Test Suite"
```

### Performance Profiling

Use Xcode Instruments to profile:
1. Product > Profile (⌘I)
2. Select profiling tool (Allocations, System Trace, etc.)
3. Run your workflow
4. Analyze results and optimize

## Troubleshooting

### Build Failures

1. **Module Not Found**: Ensure all dependencies are properly linked in target settings
2. **Code Signing**: Verify code signing identity in Build Settings
3. **Swift Version**: Confirm all files use Swift 5.9+
4. **Deployment Target**: All targets should target macOS 14.0+

### Test Failures

1. Check test output for specific assertion failures
2. Use breakpoints during test runs (Xcode debugger)
3. Verify temp directories have write permissions
4. Check for resource file dependencies

### System Extension Issues

1. Check extension is properly signed
2. Verify entitlements are present
3. Run `systemextensionsctl list` to check extension status
4. Review system logs: `log stream --predicate 'process == "kernel"'`

## Resources

- [Xcode Help](https://help.apple.com/xcode/)
- [System Extensions Documentation](https://developer.apple.com/documentation/systemextensions)
- [PDFKit Documentation](https://developer.apple.com/documentation/pdfkit)
- [App Sandbox Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements)

