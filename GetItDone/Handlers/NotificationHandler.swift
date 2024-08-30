//
//  NotificationHandler.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/27/24.
//

import Foundation
import UIKit

struct NotificationHandler {
    // Common method to handle date picker changes
    func handleDatePickerChange(for item: Item, with identifier: String, date: Date, dataToggle: UIButton, itemName: String) {
        if dataToggle.isSelected {
            Task {
                await handleNotifications(with: identifier, date: date, itemName: itemName)
            }
            item.scheduleIdentifier = identifier
            item.scheduledDate = date
        }
    }
    
    private func handleNotifications(with identifier: String, date: Date, itemName: String) async {
        let hasAccess = await requestNotificationAuthorization()
        DispatchQueue.main.async {
            if hasAccess {
                print("User granted notification access.")
                Task {
                    await self.setupScheduledNotification(with: identifier, date: date, itemName: itemName)
                }
            } else {
                print("User denied notification access.")
            }
        }
    }
    
    private func requestNotificationAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted ?? false
        case .denied:
            print("Notification access denied")
            return false
        case .authorized:
            print("Notification access granted.")
            return true
        default:
            return false
        }
    }
    
    private func setupScheduledNotification(with identifier: String, date: Date, itemName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "Time to get it done"
        content.body = itemName
        
        let dateComponents = Calendar.current.dateComponents([.day, .year, .hour, .minute], from: date)
        
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        do {
            try await notificationCenter.add(request)
        } catch {
            // Handle errors that may occur during add.
            print(error)
        }
    }
}

