//
//  NotificationManager.swift
//  DualNBack
//
//  Manages daily reminder notifications
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private let notificationIdentifier = "dailyReminder"
    private let notificationTitle = "Time to train your brain!"
    private let notificationBody = "Play Dual N-Back now 🧠"
    
    private init() {}
    
    /// Request notification permissions (should be called on app launch)
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted")
                // If permission granted and daily reminder is enabled, schedule notification
                if UserDefaults.standard.bool(forKey: "dailyReminderEnabled") {
                    self.scheduleDailyNotification()
                }
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    /// Schedule a daily notification at 9am local time
    func scheduleDailyNotification() {
        // Remove any existing notification first
        cancelDailyNotification()
        
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = .default
        
        // Create date components for 9am
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        // Create trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Daily notification scheduled for 9am")
            }
        }
    }
    
    /// Cancel the daily notification
    func cancelDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        print("Daily notification cancelled")
    }
    
    /// Check if notifications are authorized
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
}
