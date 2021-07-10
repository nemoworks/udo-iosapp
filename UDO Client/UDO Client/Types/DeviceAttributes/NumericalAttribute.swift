//
//  NumericalAttribute.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/9.
//

import UIKit

class NumericalAttribute: NSObject, Identifiable {
    let name: String
    var value: Float64
    var id:String {return name}
    
    
    public override var description: String {return "\(self.name): \(self.value)"}
    
    init(name:String, value: Float64) {
        self.name = name
        self.value = value
    }
    
}
