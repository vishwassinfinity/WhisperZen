//
//  UserPreferences.swift
//  WhisperZen
//
//  User Preferences and Settings Management
//

import SwiftUI
import Foundation
import Combine

@MainActor
class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @Published var showNotifications: Bool {
        didSet { UserDefaults.standard.set(showNotifications, forKey: "showNotifications") }
    }
    
    @Published var notificationInterval: NotificationInterval {
        didSet { UserDefaults.standard.set(notificationInterval.rawValue, forKey: "notificationInterval") }
    }
    
    @Published var autoChangeQuote: Bool {
        didSet { UserDefaults.standard.set(autoChangeQuote, forKey: "autoChangeQuote") }
    }
    
    @Published var autoChangeInterval: AutoChangeInterval {
        didSet { UserDefaults.standard.set(autoChangeInterval.rawValue, forKey: "autoChangeInterval") }
    }
    
    @Published var preferredCategories: Set<QuoteCategory> {
        didSet {
            let categoryStrings = preferredCategories.map { $0.rawValue }
            UserDefaults.standard.set(categoryStrings, forKey: "preferredCategories")
        }
    }
    
    @Published var useOnlineQuotes: Bool {
        didSet { UserDefaults.standard.set(useOnlineQuotes, forKey: "useOnlineQuotes") }
    }
    
    @Published var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin") }
    }
    
    @Published var menuBarIcon: MenuBarIcon {
        didSet { UserDefaults.standard.set(menuBarIcon.rawValue, forKey: "menuBarIcon") }
    }
    
    @Published var popoverSize: PopoverSize {
        didSet { UserDefaults.standard.set(popoverSize.rawValue, forKey: "popoverSize") }
    }
    
    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled") }
    }
    
    @Published var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode") }
    }
    
    private init() {
        self.showNotifications = UserDefaults.standard.bool(forKey: "showNotifications")
        self.notificationInterval = NotificationInterval(rawValue: UserDefaults.standard.string(forKey: "notificationInterval") ?? "") ?? .daily
        self.autoChangeQuote = UserDefaults.standard.bool(forKey: "autoChangeQuote")
        self.autoChangeInterval = AutoChangeInterval(rawValue: UserDefaults.standard.string(forKey: "autoChangeInterval") ?? "") ?? .hourly
        self.useOnlineQuotes = UserDefaults.standard.bool(forKey: "useOnlineQuotes")
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
        self.menuBarIcon = MenuBarIcon(rawValue: UserDefaults.standard.string(forKey: "menuBarIcon") ?? "") ?? .quote
        self.popoverSize = PopoverSize(rawValue: UserDefaults.standard.string(forKey: "popoverSize") ?? "") ?? .medium
        self.soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        self.appearanceMode = AppearanceMode(rawValue: UserDefaults.standard.string(forKey: "appearanceMode") ?? "") ?? .auto
        
        let categoryStrings = UserDefaults.standard.stringArray(forKey: "preferredCategories") ?? []
        self.preferredCategories = Set(categoryStrings.compactMap { QuoteCategory(rawValue: $0) })
        
        if self.preferredCategories.isEmpty {
            self.preferredCategories = Set(QuoteCategory.allCases)
        }
    }
}

enum NotificationInterval: String, CaseIterable {
    case never = "never"
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    
    var displayName: String {
        switch self {
        case .never: return "Never"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }
    
    var timeInterval: TimeInterval? {
        switch self {
        case .never: return nil
        case .daily: return 24 * 60 * 60
        case .weekly: return 7 * 24 * 60 * 60
        case .monthly: return 30 * 24 * 60 * 60
        }
    }
}

enum AutoChangeInterval: String, CaseIterable {
    case never = "never"
    case hourly = "hourly"
    case daily = "daily"
    case weekly = "weekly"
    
    var displayName: String {
        switch self {
        case .never: return "Never"
        case .hourly: return "Every Hour"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }
    
    var timeInterval: TimeInterval? {
        switch self {
        case .never: return nil
        case .hourly: return 60 * 60
        case .daily: return 24 * 60 * 60
        case .weekly: return 7 * 24 * 60 * 60
        }
    }
}

enum MenuBarIcon: String, CaseIterable {
    case quote = "quote.bubble"
    case zen = "leaf"
    case wisdom = "brain.head.profile"
    case inspiration = "lightbulb"
    case mindfulness = "circle.hexagongrid"
    
    var displayName: String {
        switch self {
        case .quote: return "Quote Bubble"
        case .zen: return "Zen Leaf"
        case .wisdom: return "Wisdom"
        case .inspiration: return "Inspiration"
        case .mindfulness: return "Mindfulness"
        }
    }
}

enum PopoverSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    
    var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
    
    var dimensions: CGSize {
        switch self {
        case .small: return CGSize(width: 300, height: 200)
        case .medium: return CGSize(width: 400, height: 280)
        case .large: return CGSize(width: 500, height: 360)
        }
    }
}

enum AppearanceMode: String, CaseIterable {
    case auto = "auto"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}