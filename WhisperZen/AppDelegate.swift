import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "quote.bubble", accessibilityDescription: "WhisperZen")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Configure the popover with your SwiftUI content
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 320, height: 180)
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }

    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
