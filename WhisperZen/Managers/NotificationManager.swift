//
//  NotificationManager.swift
//  WhisperZen
//
//  Professional Notification Management
//

import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var hasPermission = false
    
    private init() {
        checkPermission()
    }
    
    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            hasPermission = granted
            
            if granted {
                await scheduleNotifications()
            }
        } catch {
            print("Failed to request notification permission: \(error)")
            hasPermission = false
        }
    }
    
    private func checkPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleNotifications() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let preferences = UserPreferences.shared
        
        guard preferences.showNotifications,
              let interval = preferences.notificationInterval.timeInterval,
              hasPermission else {
            return
        }
        
        // Get a random quote for the notification
        let quote = QuoteManager.shared.getRandomQuote()
        
        let content = UNMutableNotificationContent()
        content.title = "WhisperZen 🧘‍♀️"
        content.body = quote.content
        content.sound = preferences.soundEnabled ? .default : nil
        content.categoryIdentifier = "QUOTE_CATEGORY"
        
        // Add custom user info
        content.userInfo = [
            "quoteId": quote.id.uuidString,
            "category": quote.category.rawValue
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: interval,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "WhisperZen.quote.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Notification scheduled for \(interval) seconds")
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    func setupNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        
        // Define actions for quote notifications
        let favoriteAction = UNNotificationAction(
            identifier: "FAVORITE_ACTION",
            title: "Add to Favorites",
            options: []
        )
        
        let newQuoteAction = UNNotificationAction(
            identifier: "NEW_QUOTE_ACTION",
            title: "New Quote",
            options: []
        )
        
        let quoteCategory = UNNotificationCategory(
            identifier: "QUOTE_CATEGORY",
            actions: [favoriteAction, newQuoteAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([quoteCategory])
    }
    
    func handleNotificationAction(identifier: String, userInfo: [AnyHashable: Any]) {
        switch identifier {
        case "FAVORITE_ACTION":
            if let quoteIdString = userInfo["quoteId"] as? String,
               let quoteId = UUID(uuidString: quoteIdString) {
                // Find and favorite the quote
                // This would require additional logic to find the quote by ID
                print("Favoriting quote: \(quoteId)")
            }
            
        case "NEW_QUOTE_ACTION":
            QuoteManager.shared.nextQuote()
            
        default:
            break
        }
    }
    
    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}