//
//  Item.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/16/24.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var name: String
    @Persisted var createdDate: Date
    @Persisted var isDone: Bool
    
}
