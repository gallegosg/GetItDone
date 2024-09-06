//
//  CategoryCell.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 9/3/24.
//

import UIKit

class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var label: UILabel!
    var settingsData = SettingsData()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        container.frame.size.height = 200
//        container.frame.size.height = 200
        container.layer.cornerRadius = 15
        
        container.layer.shadowOffset = CGSizeMake(5, 5)
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowRadius = 5
        container.layer.shadowOpacity = 0.3
        container.layer.masksToBounds = false;
        container.clipsToBounds = false;
    }

}
