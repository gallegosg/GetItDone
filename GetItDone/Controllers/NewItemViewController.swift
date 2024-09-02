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
    var notificationHandler = NotificationHandler()
    let settingsData = SettingsData()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataToggle: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        self.hideKeyboardWhenTappedAround()
        
        if let color = settingsData.getSetting(for: K.appColorKey) {
            submitButton.tintColor = UIColor(hex: color)
        }
    }
    
    func setup() {
        itemName.becomeFirstResponder()
        submitButton.layer.cornerRadius = 15
        datePicker.minimumDate = Date()

        //prefill date if edit
        if let item = editItem {
            itemName.text = item.name
            if let date = item.scheduledDate {
                datePicker.date = date
                dataToggle.isSelected = true
                datePicker.minimumDate = date
            }
            titleLabel.text = "Edit"            
        }
        
        let checkedImage = UIImage(systemName: "checkmark.circle")! as UIImage
        let uncheckedImage = UIImage(systemName: "circle")! as UIImage
        
        dataToggle.setImage(checkedImage, for: UIControl.State.selected)
        dataToggle.setTitleColor(.accent, for: .selected)
        
        dataToggle.setImage(uncheckedImage, for: UIControl.State.normal)
        dataToggle.setTitleColor(.label, for: .normal)
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
    
    @IBAction func dateToggleSwitched(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        dataToggle.isSelected = true
    }
    
    // Method to update an existing item
    private func updateExistingItem(_ item: Item, with identifier: String) {
        do {
            try self.realm.write {
                item.name = itemName.text!
                notificationHandler.handleDatePickerChange(for: item, with: identifier, date: datePicker.date, dataToggle: dataToggle, itemName: itemName.text!)
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
        
        notificationHandler.handleDatePickerChange(for: newItem, with: identifier, date: datePicker.date, dataToggle: dataToggle, itemName: itemName.text!)
        
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
