//
//  ItemTableViewCell.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 9/2/24.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var shadowLayer: UIView!
    @IBOutlet weak var itemDate: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
        mainView.layer.cornerRadius = 15

        mainView.layer.shadowOffset = CGSizeMake(5, 5)
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowRadius = 5
        mainView.layer.shadowOpacity = 0.3
        mainView.layer.masksToBounds = false;
        mainView.clipsToBounds = false;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}

