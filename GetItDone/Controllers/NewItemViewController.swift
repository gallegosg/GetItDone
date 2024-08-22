//
//  NewItemViewController.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/18/24.
//

import UIKit
import RealmSwift

protocol NewItemViewConotrollerDelegate {
    func didDismissNewItemView()
}

class NewItemViewController: UIViewController {
    let realm = try! Realm()
    var currentCategory: Category?
    var datePickerIsChanged: Bool = false
    var delegate: NewItemViewConotrollerDelegate?
    var onDismiss: (() -> Void)?

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var itemName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround() 
    }

    @IBAction func datePickerUpdated(_ sender: UIDatePicker) {
        datePickerIsChanged = true
    }
    @IBAction func createButtonPressed(_ sender: UIButton) {
        let identifier = UUID().uuidString
        let newItem = Item()
        newItem.name = itemName.text!
        newItem.createdDate = Date()

        //create notification
        if datePickerIsChanged {
            Task {
                await handleNotifications(with: identifier)
            }
            newItem.scheduleIdentifier = identifier
            newItem.scheduledDate = datePicker.date
        }
        
        guard let category = currentCategory else {
            fatalError("No category found")
        }
        do {
            try self.realm.write {
                category.items.append(newItem)
            }
            
            dismiss(animated: true) {
                self.onDismiss?()
            }
        } catch {
            print(error)
        }
    }
    
    func requestNotificationAuthorization() async -> Bool {
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
    
    func handleNotifications(with identifier: String) async {
        let hasAccess = await requestNotificationAuthorization()
        DispatchQueue.main.async {
            if hasAccess {
                print("User granted notification access.")
                Task {
                    await self.setupScheduledNotification(with: identifier)
                }
            } else {
                print("User denied notification access.")
            }
        }
    }
    
    func setupScheduledNotification(with identifier: String) async {
        let content = UNMutableNotificationContent()
        content.title = "Time to get it done"
        content.body = itemName.text!
        
        let dateComponents = Calendar.current.dateComponents([.day, .year, .hour, .minute], from: datePicker.date)

           
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
