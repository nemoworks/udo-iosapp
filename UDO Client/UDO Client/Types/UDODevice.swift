//
//  Device.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/8.
//

import UIKit
import MapKit

class UDODevice: NSObject {
    let deviceID:UInt64
    let deviceName: String
    var numericalAttrs : [NumericalAttribute]?
    var textAttrs : [TextAttribute]?
    var enumAttrs : [EnumAttribute]?
    var booleanAttrs : [BooleanAttribute]?
    var history: [String:[Double]] = [:]
    var timestamp : UInt64 = 0
    var deviceLocation: MKCoordinateRegion?
    
    public override var description: String {return "Device: \(self.deviceName) @ \(self.deviceID)"}
    
    init(id:UInt64, name:String) {
        self.deviceID = id
        self.deviceName = name
    }
    
    func loadAttrs(attrs:[String:[Any]]) {
        let textAttrsDict = attrs["text"] as? [[String:String]]
        let numericalAttrsDict = attrs["numerical"] as? [[String:Any]]
        let enumAttrsDict = attrs["enum"] as? [[String:Any]]
        let booleanAttrsDict = attrs["boolean"] as? [[String:Any]]
        
        if let textAttrsDict = textAttrsDict {
            self.textAttrs = textAttrsDict.map{TextAttribute.init(contentDict: $0)}
        }
        if let numericalAttrsDict = numericalAttrsDict {
            self.numericalAttrs =  numericalAttrsDict.map{NumericalAttribute.init(contentDict: $0)}
        }
        if let enumAttrsDict = enumAttrsDict {
            self.enumAttrs = enumAttrsDict.map{EnumAttribute.init(contentDict: $0)}
            
        }
        if let booleanAttrsDict = booleanAttrsDict {
            self.booleanAttrs = booleanAttrsDict.map{BooleanAttribute.init(contentDict: $0)}
        }
        
    }
    
    func loadHistory(history: [String: [Double]]) {
        self.history = history
    }
    
    func setDeviceRegion(latitude:Double, longitude:Double) {
        self.deviceLocation = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }
    
}
