//
//  ViewController.swift
//  Todoey
//
//  Created by 吴越 on 2018/10/1.
//  Copyright © 2018年 Yue Wu. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    var todoItems: Results<Item>?
    let reaml = try!Realm()
    var selectCategory: Category?{
        didSet{
       
            self.loadItems()
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        self.loadItems()
        
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("todoitem: \(todoItems?.count ?? 1)" )
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            print("test \(item)")
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Item Loaded"
          
        }
       
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // gray out after select
        if let item = todoItems?[indexPath.row]{
//            item.done = !item.done
//            self.saveItems(item: item)
            do{
                try self.reaml.write {
                    item.done = !item.done
                }
            }catch{
                print("Can't update check \(error)")
            }
        }
        self.tableView.reloadData()
        
        
        tableView.deselectRow(at: indexPath, animated: true)//make the select highlight disappear
    }
    
    //MARK - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let currentCategory = self.selectCategory{
     
//                self.saveItems(item: item)
                try!self.reaml.write {
                    let item = Item()
                    item.title = textField.text!
                    item.createdDate = Date()
                    currentCategory.items.append(item)
                    /*This took me a while to figure out.
                    
                    Whenever the user adds a new category, we need to actually "create" that new category in the Realm. so we use realm.add(category) to write it to storage.
                    
                    but when a user creates a new todo item, we're just adding it to that selectedCategory's items List<> (and, the Category already exists in Realm at that point).  so we use the append() method
                    
                    because Realm auto-updates the database, i guess that is all we need to do to get it to save, because we're really just Updating an entry (the Category's items List<>) in the database, not adding an entirely new object.
                    
                    */
                }
            }
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //Mark - Model Manipulation Methods
    
    
    func saveItems(item: Item){
        
        reaml.add(item)
        self.tableView.reloadData()
    }
    
    
    func loadItems() -> () {
        //load data from database
        todoItems = selectCategory?.items.sorted(byKeyPath: "title", ascending: true)
        print("todoItem length \(todoItems!.count)")
        tableView.reloadData()
        
    }
    

}

//Using Extension to org the code by protocol and funcionality
extension ToDoListViewController : UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       self.todoItems = self.todoItems?.filter("title Contains[cd]%@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
       self.tableView.reloadData()
    }

    //bonus from Tom's answer, show result while typing
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count == 0{
            self.loadItems()
            //如果没有DispatchQueue.main, resignFirstResponder会在后台等待其他任务完成后执行，因此用户不能第一时间看到键盘和光标消失。DispatchQueue.mainresignFirstResponder掉到前端来立刻执行比较符合平时用户的习惯
            //as a rule of thumb, all UI related code should be on the main queue.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //tell the search bar to stop being the first responder so it will dismiss the keyboard  & cursor
            }
        }else{
            searchBarSearchButtonClicked(searchBar)
        }
    }
}
