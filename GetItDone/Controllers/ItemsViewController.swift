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
    }
    
    func delete(_ item: Item) {
        do {
            try self.realm.write {
                self.realm.delete(item)
            }
            tableView.reloadData()
        } catch {
            print(error)
        }
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
            content.image = item.isDone ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle")
            if !item.scheduleIdentifier.isEmpty {
                content.image = item.isDone ? UIImage(systemName: "clock.fill") : UIImage(systemName: "clock")
                let df = DateFormatter()
                df.dateFormat = "hh:mm a MMM dd, yyyy"
                content.secondaryText = df.string(from: item.scheduledDate)
                content.secondaryTextProperties.color = item.isDone ? UIColor.init(white: 1, alpha: 0.6) : UIColor.white
            }
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            //Write your code in here
            if let item = self.items?[indexPath.row] {
                self.delete(item)
            }
        }
        
        delete.image = UIImage(named: "deleteIcon")
                
        let swipeActions = UISwipeActionsConfiguration(actions: [delete])
        
        return swipeActions
    }
}
