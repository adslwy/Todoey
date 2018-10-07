//
//  Item.swift
//  Todoey
//
//  Created by 吴越 on 2018/10/6.
//  Copyright © 2018年 Yue Wu. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title = ""
    @objc dynamic var done = false
    @objc dynamic var createdDate: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
