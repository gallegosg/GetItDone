//
//  NewItemViewController.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/18/24.
//

import UIKit
import RealmSwift
class NewItemViewController: UIViewController {
    let realm = try! Realm()
    var currentCategory: Category?
    var datePickerIsChanged: Bool = false
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var itemName: UITextField!

    @IBAction func datePickerUpdated(_ sender: UIDatePicker) {
        datePickerIsChanged = true
    }
    @IBAction func createButtonPressed(_ sender: UIButton) {
        let newItem = Item()
        newItem.name = itemName.text!
        newItem.createdDate = Date()
        
        //create notification
        if datePickerIsChanged {
            if requestNotificationAuthorization() {
                let identifier = UUID().uuidString
                createCalendarNotification(with: identifier)
            }
        }
        
        guard let category = currentCategory else {
            fatalError("No category found")
        }
        do {
            try self.realm.write {
                category.items.append(newItem)
            }
        
            dismiss(animated: true)
        } catch {
            print(error)
        }
    }
    
    func createCalendarNotification(with identifier: String) {
        let title = "Time to Get It Done"
        let body = itemName.text!
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)

        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier]) // Remove previous pending notification with same identifier
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification \(content.title) added")
            }
        }
    }
    
    func requestNotificationAuthorization() -> Bool {
        let center = UNUserNotificationCenter.current()
        var hasAccess = false
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if granted {
                        print("Notification access granted.")
                        hasAccess = true
                    } else {
                        hasAccess = false
                        print("Notification access denied.\(String(describing: error?.localizedDescription))")
                    }
                }
            case .denied:
                print("Notification access denied")
                hasAccess = false
            case .authorized:
                print("Notification access granted.")
                hasAccess = false
            default:
                hasAccess = false
            }
        }
        return hasAccess
    }
}
