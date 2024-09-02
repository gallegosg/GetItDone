//
//  CategoryViewController.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/16/24.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    var categories: Results<Category>?
    var categoryManager = CategoryManager()
    let settingsData = SettingsData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        initApp()
    }
    
    func initApp() {
        if let color = settingsData.getSetting(for: K.appColorKey) {
            navigationController?.navigationBar.tintColor = UIColor(hex: color)
        }
    }

    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "New Category", message: "Add the name of the category", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default) { action in
            self.categoryManager.saveNew(with: textField.text!)
            self.tableView.reloadData()
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
    
    @IBAction func settingsPressed(_ sender: Any) {
        performSegue(withIdentifier: K.settingsSegue, sender: self)
    }
    
    func loadCategories() {
        categories = categoryManager.getCategories()
    }
    
    func edit(_ category: Category) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "Edit \(category.name) Category", message: "Change it up", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Save", style: .default) { action in
            self.categoryManager.edit(category: category, newName: textField.text!)
            self.tableView.reloadData()
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
        return (categories?.count ?? 0) > 0 ? categories!.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        
        if let categories = categories, !categories.isEmpty {
            let category = categories[indexPath.row]
            content.image = UIImage(systemName: "")

            content.text = category.name
        } else {
            content.text = "No categories to show"
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let categories = categories, !categories.isEmpty {
            let item = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                //Write your code in here
                if let category = self.categories?[indexPath.row] {
                    self.categoryManager.delete(category)
                    self.tableView.reloadData()
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
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let categories = categories, !categories.isEmpty {
            performSegue(withIdentifier: K.itemsSegue, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.itemsSegue {
            let destVC = segue.destination as! ItemsViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destVC.currentCategory = categories?[indexPath.row]
            }
        }
    }
}
