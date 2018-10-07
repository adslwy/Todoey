//
//  CategoryViewController.swift
//  Todoey
//
//  Created by 吴越 on 2018/10/4.
//  Copyright © 2018年 Yue Wu. All rights reserved.
//

import UIKit
import RealmSwift


class CategoryViewController: UITableViewController {
    let realm = try! Realm()
    var categoryArray: Results<Category>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.loadCategory()
    }


    // MARK: - Table view data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories"
        return cell
    }
    
    // MARK: - Data Manipulation Methods Save & Load
    func saveCategory(category: Category) -> () {
        do {
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Can't save item \(error)")
        }
        tableView.reloadData()
     
    }
    
    func loadCategory() -> () {
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    
    
    // MARK: - Add New Categories
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let category = Category()
            category.name = textField.text!  //addTextField 传入了textField值
            self.saveCategory(category: category)
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view delegate methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        //get the current select row number
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectCategory = categoryArray?[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
}
