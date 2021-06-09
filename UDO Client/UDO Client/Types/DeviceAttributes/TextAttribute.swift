//
//  TextAttribute.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/9.
//

import UIKit

class TextAttribute: NSObject {
    let name:String
    let content: String
    
    public override var description: String {return "\(self.name): \(self.content)"}
    
    init(name:String, content: String) {
        self.name = name
        self.content = content
    }
    
    init(contentDict: [String:String]) {
        self.name = contentDict["name"]!
        self.content = contentDict["content"]!
    }
    
    
}
