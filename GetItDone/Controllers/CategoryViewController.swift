//
//  CategoryViewController.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 8/16/24.
//

import UIKit
import RealmSwift
import TipKit

class CategoryViewController: UITableViewController {
    var categories: Results<Category>?
    var categoryManager = CategoryManager()
    let settingsData = SettingsData()
    var categoryTip = CategoryTip()
    
    @IBOutlet weak var addCategoryButton: UIBarButtonItem!
    private lazy var emptyListView: EmptyList = {
        let allViewsInXibArray = Bundle.main.loadNibNamed("EmptyList", owner: self, options: nil)
        let view = allViewsInXibArray?.first as! EmptyList
        view.frame = self.view.bounds
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        initApp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func initApp() {
        if let color = settingsData.getSetting(for: K.appColorKey) {
            navigationController?.navigationBar.tintColor = UIColor(hex: color)
        }
        
        tableView.register(UINib(nibName: K.categoryNibName, bundle: nil), forCellReuseIdentifier: K.categoryCellIdentifier)
        
        Task { @MainActor in
            for await shouldDisplay in categoryTip.shouldDisplayUpdates {
                if shouldDisplay {
                    let controller = TipUIPopoverViewController(categoryTip, sourceItem: addCategoryButton)
                    controller.view.tintColor = UIColor(hex: K.defaultAppColor)
                    present(controller, animated: true)
                } else if presentedViewController is TipUIPopoverViewController {
                    dismiss(animated: true)
                }
            }
        }
    }
    
    private func removeEmptyListView() {
        if emptyListView.superview != nil {
            emptyListView.removeFromSuperview()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.itemsSegue {
            let destVC = segue.destination as! ItemsViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destVC.currentCategory = categories?[indexPath.row]
            }
        }
    }

}

// MARK: - Table view data source
extension CategoryViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellIdentifier, for: indexPath) as! CategoryCell
        
        if let categories = categories, !categories.isEmpty {
            let category = categories[indexPath.row]
            cell.taskName.text = category.name
            
            var count = 0
            for item in category.items {
                if !item.isDone {
                    count += 1
                }
            }
            cell.count.text = count > 0 ? String(count) : ""
        }
                
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let categories = categories, !categories.isEmpty {
            removeEmptyListView()
            return 1
        } else {
            if emptyListView.superview == nil {
                self.view.addSubview(emptyListView)
            }
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

//MARK: - TableView Delegate
extension CategoryViewController {
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
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if let categories = categories, !categories.isEmpty {
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil,
                                              actionProvider: {
                suggestedActions in
                
                guard let category = self.categories?[indexPath.row] else {
                    fatalError("No item found")
                }
                let editAction =
                UIAction(title: NSLocalizedString("Edit", comment: ""),
                         image: UIImage(systemName: "pencil")) { action in
                    self.edit(category)
                }
                let deleteAction =
                UIAction(title: NSLocalizedString("Delete", comment: "Remove item from list"),
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive) { action in
                    self.categoryManager.delete(category)
                    self.tableView.reloadData()
                }
                return UIMenu(title: "", children: [editAction, deleteAction])
            })
        }
        return nil
    }

}
