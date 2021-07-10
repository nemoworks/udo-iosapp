//
//  TextAttribute.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/9.
//

import UIKit

class TextAttribute: NSObject, Identifiable {
    let name:String
    let content: String
    var id:String {return name}
    
    public override var description: String {return "\(self.name): \(self.content)"}
    
    init(name:String, content: String) {
        self.name = name
        self.content = content
    }
}
