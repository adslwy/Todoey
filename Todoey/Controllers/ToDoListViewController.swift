//
//  ViewController.swift
//  Todoey
//
//  Created by 吴越 on 2018/10/1.
//  Copyright © 2018年 Yue Wu. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray: Array<Item> = Array()
        //["Find Mike", "Buy Eggos", "Walking by the Street"]
    var selectCategory: Category?{
        didSet{
       
            self.loadItems()
        }
    }
    
    let defaults = UserDefaults.standard //don't use this to generate database
    
    //CoreData approach
    //UIApplication.shared.delegate as! AppDelegate return the actual object instance that is intialed from AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        
        
//        self.loadItems()
        
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

        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print(itemArray[indexPath.row])
        // gray out after select
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        /******************remove item implementation****************/
        
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row) //also need to reset the array, or when readd item will cause blak row appear
        /*****************End remove item implememtation************/
        self.saveItems()
        
        self.saveItems()
        tableView.deselectRow(at: indexPath, animated: true)//make the select highlight disappear
    }
    
    //MARK - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
         
            let item = Item(context: self.context)
            item.title = textField.text!
            item.parentCategory = self.selectCategory
            self.itemArray.append(item)
            self.saveItems()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //Mark - Model Manipulation Methods
//    func saveItems() -> (){
//        let encoder = PropertyListEncoder()
//        do{
//            let data = try encoder.encode(self.itemArray)
//            try data.write(to: self.dataFilePath!)
//        }catch{
//            print(error)
//        }
//        self.tableView.reloadData()
//    }
//
    
    
//    func loadItems() -> (){
//        if let data = try? Data(contentsOf: dataFilePath!){
//            let decoder = PropertyListDecoder()
//            do{
//                itemArray = try decoder.decode(Array<Item>.self, from: data)
//            }catch{
//                print(error)
//            }
//
//        }
//
//    }
    
    
    func saveItems(){
        do {
            try self.context.save()
        }catch{
            print(error)
        }
        self.tableView.reloadData()
    }
    
    
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest(), predict:NSPredicate? = nil) -> () {
        //load data from database
        let parentPredicate = NSPredicate(format: "parentCategory.name MATCHES[cd] %@", selectCategory!.name!)
        do{
            if let additionalPredict = predict{
                let compondPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [parentPredicate, additionalPredict])
                request.predicate = compondPredicate
                
            }else{
                request.predicate = parentPredicate
                
            }
            self.itemArray = try self.context.fetch(request)
        }catch{
            print("load data error \(error)")
        }
        tableView.reloadData()
        
    }
    

}

//Using Extension to org the code by protocol and funcionality
extension ToDoListViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) //[cd] means query case&diacrtic insensitive
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)] //sort result
        loadItems(with: request, predict: predicate)
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
