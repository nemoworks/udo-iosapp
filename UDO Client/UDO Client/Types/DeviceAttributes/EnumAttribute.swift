//
//  EnumAttribute.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/9.
//

import UIKit

class EnumAttribute: NSObject, Identifiable {
    var name: String
    var options: [String]
    var currentOption: String
    let editable: Bool
    var id:String{return name}
    
    public override var description: String {
        return "\(self.name) \(self.options) \(self.editable) \(self.currentOption)"
    }
    
    init(name: String, options: [String], currentOption: String, editable: Bool) {
        self.name = name
        self.options = options
        self.currentOption = currentOption
        self.editable = editable
    }
    
}
