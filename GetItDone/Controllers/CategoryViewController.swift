//
//  CategoryViewController.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/16/24.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    let realm = try! Realm()
    var categories: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "New Category", message: "Add the name of the category", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default) { action in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.createdDate = Date()
            self.save(category: newCategory)
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { action in
            self.dismiss(animated: true)
        }
        
        alertController.addTextField { alertTextField in
            alertTextField.placeholder = "Name"
            textField = alertTextField
        }
        alertController.addAction(alertAction)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
        
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
    }
    
    func save(category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func delete(_ category: Category) {
        do {
            try self.realm.write {
                self.realm.delete(category)
            }
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func edit(_ category: Category) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "Edit \(category.name) Category", message: "Change it up", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Save", style: .default) { action in
            do {
                try self.realm.write {
                    category.name = textField.text!
                }
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { action in
            self.dismiss(animated: true)
        }
        
        alertController.addTextField { alertTextField in
            alertTextField.text = category.name
            textField = alertTextField
        }
        alertController.addAction(alertAction)
        alertController.addAction(dismissAction)
        
        
        present(alertController, animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        
        if let category = categories?[indexPath.row]{
            content.text = category.name
        } else {
            content.text = "No categories to show"
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            //Write your code in here
            if let category = self.categories?[indexPath.row] {
                self.delete(category)
            }
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { contextualAction, view, boolValue in
            if let category = self.categories?[indexPath.row] {
                self.edit(category)
            }
        }
        item.image = UIImage(named: "deleteIcon")
        
        edit.backgroundColor = UIColor.systemBlue
        
        let swipeActions = UISwipeActionsConfiguration(actions: [item, edit])
        
        return swipeActions
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ItemsViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destVC.currentCategory = categories?[indexPath.row]
        }
    }
    
}
