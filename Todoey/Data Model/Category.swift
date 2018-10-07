//
//  Category.swift
//  Todoey
//
//  Created by 吴越 on 2018/10/6.
//  Copyright © 2018年 Yue Wu. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name:String = ""
    let items = List<Item>()
}
