//
//  CategoriesViewCollectionViewController.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 9/3/24.
//

import UIKit
import RealmSwift

class CategoriesViewCollectionViewController: UICollectionViewController {
    var categories: Results<Category>?
    var categoryManager = CategoryManager()
    var settingsData = SettingsData()
    
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        collectionView.register(UINib(nibName: K.categoryNibName, bundle: nil), forCellWithReuseIdentifier: K.categoryCellIdentifier)
        title = "Categories"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    func initApp() {
        if let color = settingsData.getSetting(for: K.appColorKey) {
            navigationController?.navigationBar.tintColor = UIColor(hex: color)
        }
    }
    
    func loadCategories() {
        categories = categoryManager.getCategories()
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "New Category", message: "Add the name of the category", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default) { action in
            self.categoryManager.saveNew(with: textField.text!)
            self.collectionView.reloadData()
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
    @IBAction func settingsPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.settingsSegue, sender: self)

    }
    
    private func edit(_ category: Category) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "Edit \(category.name) Category", message: "Change it up", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Save", style: .default) { action in
            self.categoryManager.edit(category: category, newName: textField.text!)
            self.collectionView.reloadData()
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
        if segue.identifier == "newCatToItems" {
            let destVC = segue.destination as! ItemsViewController

            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                destVC.currentCategory = categories?[indexPath.row]
            }
        }
    }
    
    private func removeEmptyListView() {
        if emptyListView.superview != nil {
            emptyListView.removeFromSuperview()
        }
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
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
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return categories?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.categoryCellIdentifier, for: indexPath) as! CategoryCell
    
        // Configure the cell
        if let categories = categories, !categories.isEmpty {
            let category = categories[indexPath.row]
            cell.label.text = category.name

            if let color = settingsData.getSetting(for: K.appColorKey) {
                cell.container.backgroundColor = UIColor(hex: color)
            }
        } else {
            cell.label.text = "No categories to show"
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let categories = categories, !categories.isEmpty {
            performSegue(withIdentifier: "newCatToItems", sender: self)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        if let categories = categories, !categories.isEmpty {
            if let row = indexPaths.first?.row {
                
                return UIContextMenuConfiguration(identifier: nil,
                                                  previewProvider: nil,
                                                  actionProvider: {
                    suggestedActions in
                    
                    let category = categories[row]
                    
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
                        self.collectionView.reloadData()
                    }
                    return UIMenu(title: "", children: [editAction, deleteAction])
                })
            }
        }
        return nil
    }
    
}

extension CategoriesViewCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        
        let size = (screenSize.width / 2) - 10
        
        return CGSize(width: size, height: size)
    }
}
