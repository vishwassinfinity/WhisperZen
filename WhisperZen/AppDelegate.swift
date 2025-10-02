import SwiftUI
import AppKit
import UserNotifications
import UniformTypeIdentifiers

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var preferences = UserPreferences.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        setupNotifications()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusItemIcon()
        
        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func updateStatusItemIcon() {
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: preferences.menuBarIcon.rawValue,
                accessibilityDescription: "WhisperZen"
            )
        }
    }
    
    private func setupPopover() {
        popover.behavior = .transient
        updatePopoverSize()
        popover.contentViewController = NSHostingController(
            rootView: ContentView()
                .environmentObject(preferences)
        )
    }
    
    private func updatePopoverSize() {
        popover.contentSize = preferences.popoverSize.dimensions
    }
    
    private func setupNotifications() {
        // Request notification permissions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        
        // Schedule periodic notifications if enabled
        scheduleNotifications()
    }
    
    private func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        guard preferences.showNotifications,
              let interval = preferences.notificationInterval.timeInterval else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "WhisperZen"
        content.body = "Time for some inspiration! ✨"
        content.sound = preferences.soundEnabled ? .default : nil
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: interval,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "WhisperZen.quote",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton?) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
            return
        }
        
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            // Update popover size and icon before showing
            updatePopoverSize()
            updateStatusItemIcon()
            
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Open WhisperZen", action: #selector(openApp), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "New Quote", action: #selector(newQuote), keyEquivalent: "n"))
        menu.addItem(NSMenuItem(title: "Favorites", action: #selector(showFavorites), keyEquivalent: "f"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit WhisperZen", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    @objc private func openApp() {
        togglePopover(statusItem.button)
    }
    
    @objc private func newQuote() {
        QuoteManager.shared.nextQuote()
        if preferences.soundEnabled {
            NSSound(named: "Ping")?.play()
        }
    }
    
    @objc private func showFavorites() {
        // Implementation would open favorites window
        print("Show favorites")
    }
    
    @objc private func showSettings() {
        // Implementation would open settings window
        print("Show settings")
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
