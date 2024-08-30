//
//  CategoryManager.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/29/24.
//

import Foundation
import RealmSwift

struct CategoryManager {
    let realm = try! Realm()
    
    func saveNew(with name: String){
        let newCategory = Category()
        newCategory.name = name
        newCategory.createdDate = Date()
        do {
            try realm.write {
                realm.add(newCategory)
            }
        } catch {
            print(error)
        }
    }
    
    func edit(category: Category, newName: String) {
        do {
            try realm.write {
                category.name = newName
            }
        } catch {
            print(error)
        }
    }
    
    func delete(_ category: Category) {
        do {
            try realm.write {
                realm.delete(category)
            }
        } catch {
            print(error)
        }
    }
    
    func getCategories() -> Results<Category> {
        return realm.objects(Category.self)
    }
}
