//
//  ItemsViewController.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/17/24.
//

import UIKit
import RealmSwift

class ItemsViewController: UITableViewController {
    let realm = try! Realm()

    var items: Results<Item>?
    var currentCategory: Category? {
        didSet {
            loadItems()
        }
    }

    func loadItems() {
        items = currentCategory?.items.sorted(byKeyPath: "name", ascending: true)
        title = currentCategory?.name
    }
    
    func update(_ item: Item) {
        do {
            try realm.write {
                item.isDone = !item.isDone
            }
            tableView.reloadData()
        } catch {
            print("could not update item \(error)")
        }
    }
    
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToNewItem", sender: self)
//        var textField = UITextField()
//        let alertController = UIAlertController(title: "New Item", message: "Add the name of the item", preferredStyle: .alert)
//        let alertAction = UIAlertAction(title: "Add", style: .default) { action in
//            let newItem = Item()
//            newItem.name = textField.text!
//            newItem.createdDate = Date()
//            do {
//                try self.realm.write {
//                    self.currentCategory?.items.append(newItem)
//                }
//                self.tableView.reloadData()
//            } catch {
//                print(error)
//            }
//        }
//        
//        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { action in
//            self.dismiss(animated: true)
//        }
//        
//        alertController.addTextField { alertTextField in
//            alertTextField.placeholder = "Name"
//            textField = alertTextField
//        }
//        alertController.addAction(alertAction)
//        alertController.addAction(dismissAction)
        
//        present(alertController, animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        if let item = items?[indexPath.row] {
            content.text = item.name
            content.textProperties.color = item.isDone ? UIColor.init(white: 1, alpha: 0.6) : UIColor.white
            cell.accessoryType = item.isDone ? .checkmark : .none
        } else {
            content.text = "No items in this category. Try to add some."
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    //MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            update(item)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! NewItemViewController
        destVC.currentCategory = currentCategory
    }
}
