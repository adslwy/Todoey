//
//  Item.swift
//  Todoey
//
//  Created by 吴越 on 2018/10/2.
//  Copyright © 2018年 Yue Wu. All rights reserved.
//

import Foundation

class Item:Codable {
    var title:String = ""
    var done: Bool = false
    init(_ title:String, done:Bool = false) {
        self.title = title
        self.done = done
    }
    
}
