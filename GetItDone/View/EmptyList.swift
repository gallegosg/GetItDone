//
//  EmptyList.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 9/5/24.
//

import UIKit

class EmptyList: UIView {

    @IBOutlet weak var image: UIImageView!
    let settingsData = SettingsData()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // Called when the view has been added or removed from its superview
        if superview != nil {
            // View has been added to a superview
            commonInit()
        }
    }
    
    private func commonInit() {
        // Perform initialization tasks here
        // For example, setup subviews, add constraints, configure appearance
        if let color = settingsData.getSetting(for: K.appColorKey) {
            image.tintColor = UIColor(hex: color)
        }
    }
}
