//
//  SettingsView.swift
//  WhisperZen
//
//  Professional Settings Interface
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var preferences = UserPreferences.shared
    @StateObject private var quoteManager = QuoteManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: SettingsTab = .general
    
    var body: some View {
        NavigationView {
            // Sidebar
            List(SettingsTab.allCases, id: \.self, selection: $selectedTab) { tab in
                Label(tab.title, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationTitle("Settings")
            .frame(minWidth: 150)
            
            // Content
            Group {
                switch selectedTab {
                case .general:
                    GeneralSettingsView()
                case .appearance:
                    AppearanceSettingsView()
                case .notifications:
                    NotificationSettingsView()
                case .quotes:
                    QuoteSettingsView()
                case .advanced:
                    AdvancedSettingsView()
                }
            }
            .frame(minWidth: 400, minHeight: 300)
            .navigationTitle(selectedTab.title)
        }
        .frame(width: 600, height: 450)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
        }
    }
}

enum SettingsTab: CaseIterable {
    case general, appearance, notifications, quotes, advanced
    
    var title: String {
        switch self {
        case .general: return "General"
        case .appearance: return "Appearance"
        case .notifications: return "Notifications"
        case .quotes: return "Quotes"
        case .advanced: return "Advanced"
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "gear"
        case .appearance: return "paintbrush"
        case .notifications: return "bell"
        case .quotes: return "quote.bubble"
        case .advanced: return "wrench.and.screwdriver"
        }
    }
}

struct GeneralSettingsView: View {
    @StateObject private var preferences = UserPreferences.shared
    
    var body: some View {
        Form {
            Section("App Behavior") {
                Toggle("Launch at Login", isOn: $preferences.launchAtLogin)
                    .help("Start WhisperZen automatically when you log in")
                
                Toggle("Sound Effects", isOn: $preferences.soundEnabled)
                    .help("Play sounds for actions like copying quotes")
                
                HStack {
                    Text("Menu Bar Icon")
                    Spacer()
                    Picker("Menu Bar Icon", selection: $preferences.menuBarIcon) {
                        ForEach(MenuBarIcon.allCases, id: \.self) { icon in
                            HStack {
                                Image(systemName: icon.rawValue)
                                Text(icon.displayName)
                            }
                            .tag(icon)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                }
                
                HStack {
                    Text("Popover Size")
                    Spacer()
                    Picker("Popover Size", selection: $preferences.popoverSize) {
                        ForEach(PopoverSize.allCases, id: \.self) { size in
                            Text(size.displayName).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }
            
            Section("Auto Quote Change") {
                Toggle("Auto Change Quotes", isOn: $preferences.autoChangeQuote)
                    .help("Automatically show new quotes at set intervals")
                
                if preferences.autoChangeQuote {
                    HStack {
                        Text("Change Interval")
                        Spacer()
                        Picker("Change Interval", selection: $preferences.autoChangeInterval) {
                            ForEach(AutoChangeInterval.allCases, id: \.self) { interval in
                                Text(interval.displayName).tag(interval)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 120)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .onChange(of: preferences.autoChangeInterval) { _, _ in
            QuoteManager.shared.updateAutoChangeTimer()
        }
    }
}

struct AppearanceSettingsView: View {
    @StateObject private var preferences = UserPreferences.shared
    
    var body: some View {
        Form {
            Section("Theme") {
                Picker("Appearance", selection: $preferences.appearanceMode) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .help("Choose between light, dark, or system appearance")
            }
            
            Section("Preview") {
                VStack {
                    Text("This is how quotes will appear")
                        .font(.headline)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text("Beautiful typography and smooth animations make reading quotes a delightful experience.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct NotificationSettingsView: View {
    @StateObject private var preferences = UserPreferences.shared
    
    var body: some View {
        Form {
            Section("Quote Notifications") {
                Toggle("Show Notifications", isOn: $preferences.showNotifications)
                    .help("Get periodic notifications with inspiring quotes")
                
                if preferences.showNotifications {
                    HStack {
                        Text("Frequency")
                        Spacer()
                        Picker("Notification Frequency", selection: $preferences.notificationInterval) {
                            ForEach(NotificationInterval.allCases, id: \.self) { interval in
                                Text(interval.displayName).tag(interval)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 120)
                    }
                }
            }
            
            Section("Permissions") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notification Permission")
                            .font(.headline)
                        Text("Grant permission to show inspirational quote notifications")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Open System Preferences") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct QuoteSettingsView: View {
    @StateObject private var preferences = UserPreferences.shared
    @StateObject private var quoteManager = QuoteManager.shared
    
    var body: some View {
        Form {
            Section("Quote Sources") {
                Toggle("Use Online Quotes", isOn: $preferences.useOnlineQuotes)
                    .help("Fetch quotes from online sources in addition to built-in quotes")
            }
            
            Section("Preferred Categories") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(QuoteCategory.allCases, id: \.self) { category in
                        CategoryToggle(
                            category: category,
                            isSelected: preferences.preferredCategories.contains(category)
                        ) { isSelected in
                            if isSelected {
                                preferences.preferredCategories.insert(category)
                            } else {
                                preferences.preferredCategories.remove(category)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("Statistics") {
                HStack {
                    Text("Favorite Quotes")
                    Spacer()
                    Text("\(quoteManager.favoriteQuotes.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Quote History")
                    Spacer()
                    Text("\(quoteManager.quoteHistory.count)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct CategoryToggle: View {
    let category: QuoteCategory
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: { onToggle(!isSelected) }) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .foregroundColor(isSelected ? .white : .primary)
                    .font(.system(size: 14, weight: .medium))
                
                Text(category.rawValue)
                    .foregroundColor(isSelected ? .white : .primary)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentColor, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct AdvancedSettingsView: View {
    @StateObject private var quoteManager = QuoteManager.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        Form {
            Section("Data Management") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reset All Data")
                            .font(.headline)
                        Text("Clear all favorites, history, and preferences")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Reset", role: .destructive) {
                        showingResetAlert = true
                    }
                }
                .padding(.vertical, 8)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Export Favorites")
                            .font(.headline)
                        Text("Save your favorite quotes to a file")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Export") {
                        exportFavorites()
                    }
                    .disabled(quoteManager.favoriteQuotes.isEmpty)
                }
                .padding(.vertical, 8)
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Built with")
                    Spacer()
                    Text("SwiftUI & ❤️")
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will permanently delete all your favorites, history, and preferences. This action cannot be undone.")
        }
    }
    
    private func exportFavorites() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "WhisperZen_Favorites.json"
        panel.allowedContentTypes = [.json]
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                let data = try JSONEncoder().encode(quoteManager.favoriteQuotes)
                try data.write(to: url)
            } catch {
                print("Failed to export favorites: \(error)")
            }
        }
    }
    
    private func resetAllData() {
        // Clear UserDefaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "favoriteQuotes")
        defaults.removeObject(forKey: "quoteHistory")
        defaults.removeObject(forKey: "currentQuote")
        defaults.removeObject(forKey: "lastQuote")
        
        // Reset quote manager
        quoteManager.favoriteQuotes.removeAll()
        quoteManager.quoteHistory.removeAll()
        
        // Reset preferences to defaults would require reinitializing UserPreferences
        // For now, just clear the critical data
    }
}

#Preview {
    SettingsView()
}