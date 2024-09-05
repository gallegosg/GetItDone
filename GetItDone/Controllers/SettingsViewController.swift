//
//  SettingsViewController.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/31/24.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var colorPicker: UIColorWell!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    let notificationHandler = NotificationHandler()
    
    let settingsData = SettingsData()
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        colorPicker.addTarget(self, action: #selector(colorDidChange(_:)), for: .valueChanged)

        if let color = settingsData.getSetting(for: K.appColorKey) {
            print("settings view setup color", color)
            colorPicker.selectedColor = UIColor(hex: color)
            settingsButton.tintColor = UIColor(hex: color)
        }
        
        Task {
            notificationsLabel.text = await notificationHandler.checkNotificationStatus() ? "Notifications Enabled" : "Notifications Disabled"
        }
    }

    @objc func colorDidChange(_ sender: UIColorWell) {
        if let selectedColor = sender.selectedColor {
            if let hexString = selectedColor.toHexString {
                //set user defaults
                settingsData.saveSetting(for: K.appColorKey, with: hexString)
                settingsButton.tintColor = UIColor(hex: hexString)
                
                navigationController?.navigationBar.tintColor = UIColor(hex: hexString)
            }
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }
}
