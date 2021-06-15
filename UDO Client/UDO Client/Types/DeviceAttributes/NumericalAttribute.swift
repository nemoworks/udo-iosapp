//
//  NumericalAttribute.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/9.
//

import UIKit

class NumericalAttribute: NSObject {
    let name: String
    var value: Float64
    
    public override var description: String {return "\(self.name): \(self.value)"}
    
    init(name:String, value: Float64) {
        self.name = name
        self.value = value
    }
    
    init(contentDict:[String:Any]) {
        self.name = contentDict["name"] as! String
        self.value = contentDict["value"] as! Float64
    }
}