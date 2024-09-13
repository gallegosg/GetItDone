//
//  Tips.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 9/9/24.
//

import Foundation
import TipKit

struct CategoryTip: Tip {
    var title: Text {
        Text("Add a new category")
    }
    
    var message: Text? {
        Text("Create a new category to hold your items.")
    }
    
    var asset: UIImage? {
        UIImage(systemName: "plus")
    }
}
