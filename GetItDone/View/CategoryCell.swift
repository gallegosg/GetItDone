//
//  CategoryItemCell.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 9/7/24.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var taskName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

