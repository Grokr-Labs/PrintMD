import AppKit
import os.log

private let logger = Logger(subsystem: "com.grokr-labs.printmd", category: "app")

/// Main application delegate for PrintMD.
/// Manages app lifecycle, window setup, and system extension registration.
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var statusItem: NSStatusItem?

    /// Called when the application finishes launching.
    /// Sets up the printer driver extension and UI.
    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.info("PrintMD application launching")

        // Register system extension for printer driver
        registerPrinterExtension()

        // Set up menu bar status item
        setupStatusItem()

        // Create and show settings window if needed
        createSettingsWindow()
    }

    /// Registers the printer driver system extension.
    private func registerPrinterExtension() {
        logger.info("Registering printer driver extension")
        // TODO: Implement system extension registration
        // This requires:
        // - DriverExtension target as a system extension
        // - Proper code signing and entitlements
        // - User authorization (may trigger system prompt)
    }

    /// Sets up the menu bar status item with quick access menu.
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.title = "📄"
            button.action = #selector(toggleMenu(_:))
            button.target = self
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "Settings",
            action: #selector(showSettings(_:)),
            keyEquivalent: ","
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Quit PrintMD",
            action: #selector(quitApp(_:)),
            keyEquivalent: "q"
        ))

        statusItem?.menu = menu
    }

    /// Creates and configures the main settings window.
    private func createSettingsWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "PrintMD Settings"
        window.center()

        let contentView = NSView()
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.white.cgColor

        window.contentView = contentView
        self.window = window

        logger.debug("Settings window created")
    }

    @objc func toggleMenu(_ sender: Any) {
        logger.debug("Menu toggled")
    }

    @objc func showSettings(_ sender: Any) {
        guard let window = window else { return }
        window.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    @objc func quitApp(_ sender: Any) {
        logger.info("Quit requested")
        NSApplication.shared.terminate(nil)
    }

    /// Handle application termination notifications.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false  // App stays running in menu bar
    }

    /// Called when the application is about to terminate.
    func applicationWillTerminate(_ notification: Notification) {
        logger.info("PrintMD application terminating")
        // Cleanup: remove temporary files, close driver extension, etc.
    }
}
