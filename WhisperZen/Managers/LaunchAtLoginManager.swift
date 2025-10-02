//
//  LaunchAtLoginManager.swift
//  WhisperZen
//
//  Launch at Login Management
//

import Foundation
import ServiceManagement

class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()
    
    private let launcherBundleId = "com.vishwassinfinity.WhisperZen.Launcher"
    
    private init() {}
    
    var isEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "launchAtLogin")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "launchAtLogin")
            setLaunchAtLogin(enabled: newValue)
        }
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            }
        } else {
            // Fallback for older macOS versions
            let success = SMLoginItemSetEnabled(launcherBundleId as CFString, enabled)
            if !success {
                print("Failed to \(enabled ? "enable" : "disable") launch at login")
            }
        }
    }
}