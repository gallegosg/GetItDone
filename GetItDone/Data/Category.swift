//
//  Category.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/16/24.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted var name: String
    @Persisted var createdDate: Date
    @Persisted var items: List<Item>
}
