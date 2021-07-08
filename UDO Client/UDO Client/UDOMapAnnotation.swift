//
//  UDOMapAnnotation.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/8.
//

import UIKit
import MapKit

class UDOMapAnnotation: MKPointAnnotation {
    var deviceName: String?
    static let ImageByDeviceName: [String: String] = [
        "XiaoMi Air Purifier" : "air-purifier"
    ]
    
    init(deviceName:String) {
        super.init()
        self.title = deviceName
        self.deviceName = deviceName
    }
}
