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
    
    private lazy var emptyListView: EmptyList = {
        let allViewsInXibArray = Bundle.main.loadNibNamed("EmptyList", owner: self, options: nil)
        let view = allViewsInXibArray?.first as! EmptyList
        view.frame = self.view.bounds
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
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

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! ItemTableViewCell
        
        if let items = items, !items.isEmpty {
            let item = items[indexPath.row]
            //text style for regular
            cell.itemName.text = item.name
            cell.itemName.textColor = item.isDone ? .gray : .label
            cell.itemDate.text = ""
            cell.leftImage.image = item.isDone ? UIImage(systemName: "circle.badge.checkmark.fill") : UIImage(systemName: "circle")
            
            if let id = item.scheduleIdentifier, let date = item.scheduledDate {
                //text style for schedule
                if !id.isEmpty {
                    cell.leftImage.image = item.isDone ? UIImage(systemName: "clock.badge.checkmark.fill") : UIImage(systemName: "clock")
                    let dateString = getItemDateFormat(date)
                    cell.itemDate.text = dateString
                    cell.itemDate.textColor = item.isDone ? .gray : .label
                }
            }
            
            if let color = settingsData.getSetting(for: K.appColorKey) {
                cell.tintColor = UIColor(hex: color)
            }
        } else {
            cell.itemName.text = "No items in this category. Try to add some."
        }
                
        return cell
    }
    
    private func getItemDateFormat(_ date: Date) -> String {
        let components = date.get(.day, .month, .year)
        let today = Date()
        let currentDayComponents = today.get(.day, .month, .year)
        
        let df = DateFormatter()
        df.dateFormat = "hh:mm a MMM dd, yyyy"
        var formattedDate = df.string(from: date)
        
        if let taskDay = components.day, let taskMonth = components.month, let taskYear = components.year {
            if let currentDay = currentDayComponents.day, let currentMonth = currentDayComponents.month, let currentYear = currentDayComponents.year {
                if (taskDay == currentDay && taskMonth == currentMonth && taskYear == currentYear) {
                    //only show time and today
                    df.dateFormat = "hh:mm a"
                    formattedDate = "Today at \(df.string(from: date))"
                } else if (taskYear == currentYear) {
                    // show time and month
                    df.dateFormat = "hh:mm a MMM dd"
                    formattedDate = df.string(from: date)
                } else {
                    // show time, month and year
                    df.dateFormat = "hh:mm a MMM dd, yyyy"
                    formattedDate = df.string(from: date)
                }
            }
        }
        return formattedDate
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
    
    private func removeEmptyListView() {
        if emptyListView.superview != nil {
            emptyListView.removeFromSuperview()
        }
    }

    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let items = items, !items.isEmpty {
            removeEmptyListView()
            return 1
        } else {
            if emptyListView.superview == nil {
                self.view.addSubview(emptyListView)
            }
            return 0
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
