//
// SwitchAttribute.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/9.
//

import UIKit

class BooleanAttribute: NSObject, Identifiable {
    var name: String
    var on: Bool
    var editable: Bool
    var id:String{return name}
    
    public override var description: String {return "\(self.name): \(self.on), \(self.editable)"}
    
    init(name:String, on: Bool, editable:Bool) {
        self.name = name
        self.on = on
        self.editable = editable
    }
}
