//
// SwitchAttribute.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/9.
//

import UIKit

class SwitchAttribute: NSObject {
    let name: String
    var on: Bool
    var editable: Bool
    
    public override var description: String {return "\(self.name): \(self.on), \(self.editable)"}
    
    init(name:String, on: Bool, editable:Bool) {
        self.name = name
        self.on = on
        self.editable = editable
    }
    
    init(contentDict:[String:Any]) {
        self.name = contentDict["name"] as! String
        self.on = contentDict["on"] as! Bool
        self.editable = contentDict["editable"] as! Bool
    }
}
