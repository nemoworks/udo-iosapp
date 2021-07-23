//
//  Device.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/8.
//

import UIKit
import MapKit

class UDODevice: NSObject {
    let deviceName: String
    let avatarUrl: String
    let uri: String
    let context: String
    var numericalAttrs : [NumericalAttribute]
    var textAttrs : [TextAttribute]
    var enumAttrs : [EnumAttribute]
    var booleanAttrs : [BooleanAttribute]
    var history: [String:[Double]] = [:]
    var timestamp : UInt64 = 0
    var deviceLocation: MKCoordinateRegion?
    var originObject: [String:Any]?
    public var isHass: Bool = false
    
    public override var description: String {return "Device: \(self.deviceName) @ \(self.uri)"}
    
    init( uri: String, name:String, context: String, avatarUrl:String) {
        self.deviceName = name
        self.avatarUrl = avatarUrl
        self.uri = uri
        self.context = context
        self.numericalAttrs = []
        self.textAttrs = []
        self.enumAttrs = []
        self.booleanAttrs = []
    }
    
    func loadAttrs(attrs:[String:[String:Any]]) {
        self.numericalAttrs = []
        self.textAttrs = []
        self.enumAttrs = []
        self.booleanAttrs = []
        for attr in attrs {
            let attrName = attr.key
            let attrContent = attr.value
            let catetory = attrContent["category"] as! String
            switch catetory {
            case "numerical":
                print("A numerical attr: \(attrName)")
                let value = attrContent["value"] as! Float64
                let newAttr = NumericalAttribute(name: attrName, value: value)
                self.numericalAttrs.append(newAttr)
            case "text":
                print("A text attr: \(attrName)")
                let value = attrContent["value"] as! String
                let newAttr = TextAttribute(name: attrName, content: value)
                self.textAttrs.append(newAttr)
            case "enum":
                print("A enum attr: \(attrName)")
                let value = attrContent["value"] as! String
                let optionsDict = attrContent["options"] as! [String:String]
                var options:[String] = []
                for k in Array(optionsDict.keys).sorted(by: <) {
                    options.append(optionsDict[k as String]!)
                }
                
                let editable = attrContent["editable"] as! Bool
                let newAttr = EnumAttribute(name: attrName, options: options, currentOption: value, editable: editable)
                self.enumAttrs.append(newAttr)
            case "boolean":
                print("A boolean attr: \(attrName)")
                let value = attrContent["value"] as! Bool
                let editable = attrContent["editable"] as! Bool
                let newAttr = BooleanAttribute(name: attrName, on: value, editable: editable)
                self.booleanAttrs.append(newAttr)
            default:
                print("No such kind of attr")
            }
        }
    }
    
    func loadHistory(history: [String: [Double]]) {
        self.history = history
    }
    
    func setDeviceRegion(latitude:Double, longitude:Double) {
        self.deviceLocation = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }
    
}
