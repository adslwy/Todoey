//
//  ViewController.swift
//  Todoey
//
//  Created by 吴越 on 2018/10/1.
//  Copyright © 2018年 Yue Wu. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemArray: Array<Item> = Array()
        //["Find Mike", "Buy Eggos", "Walking by the Street"]
    
    let defaults = UserDefaults.standard //don't use this to generate database
    
    //generate own plist, return its url
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        if let items = defaults.array(forKey: "TodoListArray") as? [String]{
//            self.itemArray = items
//        }
        
       
        
//        itemArray.append(Item("Find Mike"))
//        itemArray.append(Item("Buy Eggos"))
//        itemArray.append(Item("Walking by the Street"))
        self.loadItems()
        
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
//        if itemArray[indexPath.row].done == true{
//            cell.accessoryType = .checkmark
//        }else{
//            cell.accessoryType = .none
//        }
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print(itemArray[indexPath.row])
        // gray out after select
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
     
        self.saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen when user clicks the Add item button on our UIAlert
            self.itemArray.append(Item(textField.text!))
            
            self.saveItems()
//            self.defaults.set(self.itemArray, forKey: "TodoListArray")
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //Mark - Model Manipulation Methods
    func saveItems() -> (){
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        }catch{
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func loadItems() -> (){
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do{
                itemArray = try decoder.decode(Array<Item>.self, from: data)
            }catch{
                print(error)
            }
            
        }
        
    }
    
}

