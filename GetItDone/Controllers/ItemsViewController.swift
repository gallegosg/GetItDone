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
    let settingsData = SettingsData()
    
    var items: Results<Item>?
    var currentCategory: Category? {
        didSet {
            loadItems()
        }
    }

    func loadItems() {
        items = currentCategory?.items.sorted(byKeyPath: "name", ascending: true)
        title = currentCategory?.name
        tableView.reloadData()
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
    
    func goToEdit(item: Item) {
        performSegue(withIdentifier: "goToNewItem", sender: item)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (items?.count ?? 0) > 0 ? items!.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        if let items = items, !items.isEmpty {
            let item = items[indexPath.row]
            //text style for regular
            content.text = item.name
            content.textProperties.color = item.isDone ? .gray : .label
            content.image = item.isDone ? UIImage(systemName: "circle.badge.checkmark.fill") : UIImage(systemName: "circle")
            
            if let id = item.scheduleIdentifier, let date = item.scheduledDate {
                //text style for schedule
                if !id.isEmpty {
                    content.image = item.isDone ? UIImage(systemName: "clock.badge.checkmark.fill") : UIImage(systemName: "clock")
                    let df = DateFormatter()
                    df.dateFormat = "hh:mm a MMM dd, yyyy"
                    content.secondaryText = df.string(from: date)
                    content.secondaryTextProperties.color = item.isDone ? .gray : .label
                }
            }
            
            if let color = settingsData.getSetting(for: K.appColorKey) {
                cell.tintColor = UIColor(hex: color)
            }
        } else {
            content.text = "No items in this category. Try to add some."
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    //MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let items = items, !items.isEmpty {
            let item = items[indexPath.row]
            update(item)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! NewItemViewController
        destVC.currentCategory = currentCategory
        if let editItem = sender as? Item {
            destVC.editItem = editItem
        }
        destVC.onDismiss = { [weak self] in
            self?.loadItems()
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let items = items, !items.isEmpty {
            
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
        return nil
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if let items = items, !items.isEmpty {
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil,
                                              actionProvider: {
                suggestedActions in
                
                guard let item = self.items?[indexPath.row] else {
                    fatalError("No item found")
                }
                let editAction =
                UIAction(title: NSLocalizedString("Edit", comment: ""),
                         image: UIImage(systemName: "pencil")) { action in
                    self.goToEdit(item: item)
                }
                let deleteAction =
                UIAction(title: NSLocalizedString("Delete", comment: "Remove item from list"),
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive) { action in
                    self.delete(item)
                }
                return UIMenu(title: "", children: [editAction, deleteAction])
            })
        }
        return nil
    }
}

extension UIImage {
    func tinted(with color: UIColor, isOpaque: Bool = false) -> UIImage? {
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            color.set()
            withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
    }
}
