//
//  EnumAttribute.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/9.
//

import UIKit

class EnumAttribute: NSObject {
    let name: String
    let options: [String]
    let currentOption: Int
    let editable: Bool
    
    public override var description: String {
        return "\(self.name) \(self.options) \(self.editable) \(self.currentOption)"
    }
    
    init(name: String, options: [String], currentOption: Int, editable: Bool) {
        self.name = name
        self.options = options
        self.currentOption = currentOption
        self.editable = editable
    }
    
    init(contentDict: [String:Any]) {
        self.name = contentDict["name"] as! String
        self.editable = contentDict["editable"] as! Bool
        self.options = contentDict["options"] as! [String]
        self.currentOption = contentDict["value"] as! Int
    }
}
