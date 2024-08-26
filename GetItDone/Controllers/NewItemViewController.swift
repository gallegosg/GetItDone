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
    var delegate: NewItemViewConotrollerDelegate?
    var onDismiss: (() -> Void)?
    var editItem: Item?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateToggle: UISwitch!
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setup()
        self.hideKeyboardWhenTappedAround()
    }
    
    func setup() {
        itemName.becomeFirstResponder()
        submitButton.layer.cornerRadius = 15
        dateToggle.setOn(false, animated: false)
        datePicker.isEnabled = false
        
        //prefill date if edit
        if let item = editItem {
            itemName.text = item.name
            if let date = item.scheduledDate {
                datePicker.date = date
                dateToggle.isOn = true
                datePicker.isEnabled = true
            }
            titleLabel.text = "Edit"
            submitButton.setTitle("Save", for: .normal)
            submitButton.imageView?.image = .none
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, itemName.bounds.height + 3, itemName.bounds.width, 1.0)
        bottomLine.backgroundColor = UIColor.init(white: 1, alpha: 0.2).cgColor
        itemName.borderStyle = UITextField.BorderStyle.none
        itemName.layer.addSublayer(bottomLine)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        let identifier = UUID().uuidString
        
        if let item = editItem {
            updateExistingItem(item, with: identifier)
        } else {
            createNewItem(with: identifier)
        }

        dismiss(animated: true) {
            self.onDismiss?()
        }
    }
    @IBAction func dateToggleSwitched(_ sender: UISwitch) {
        if sender.isOn {
            datePicker.isEnabled = true
        } else {
            datePicker.isEnabled = false
        }
    }
    
    // Method to update an existing item
    private func updateExistingItem(_ item: Item, with identifier: String) {
        do {
            try self.realm.write {
                item.name = itemName.text!
                handleDatePickerChange(for: item, with: identifier)
            }
        } catch {
            print(error)
        }
    }

    // Method to create a new item
    private func createNewItem(with identifier: String) {
        let newItem = Item()
        newItem.name = itemName.text!
        newItem.createdDate = Date()
        
        handleDatePickerChange(for: newItem, with: identifier)
        
        guard let category = currentCategory else {
            fatalError("No category found")
        }
        
        do {
            try self.realm.write {
                category.items.append(newItem)
            }
        } catch {
            print(error)
        }
    }
    
    // Common method to handle date picker changes
    private func handleDatePickerChange(for item: Item, with identifier: String) {
        if dateToggle.isOn {
            Task {
                await handleNotifications(with: identifier)
            }
            item.scheduleIdentifier = identifier
            item.scheduledDate = datePicker.date
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
