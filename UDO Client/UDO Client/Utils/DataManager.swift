//
//  DataManager.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/19.
//

import UIKit
import CocoaMQTT

protocol OnMessageDelegate: AnyObject {
    func refresh()
}

class DataManager: NSObject {
    public var contexts: [String] = []
    public var devices: [UDODevice] = []
    public weak var resourceFoundDelegate: OnMessageDelegate?
    public weak var contextFoundDelegate: OnMessageDelegate?
    let userNotificationCenter = UNUserNotificationCenter.current()
    public static var shared: DataManager = DataManager()
    
    private override init() {
        super.init()
    }
    
    func getDevicesByContext(context:String)->[UDODevice] {
        var devicesInContext:[UDODevice] = []
        for device in self.devices {
            if device.context == context {
                devicesInContext.append(device)
            }
        }
        return devicesInContext
    }
    
    func parseUDODevice(data: Data, context:String)->UDODevice? {
        do {
            let contentDict = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
            print("Parse to dictionary:  \(contentDict)")
            
            var name = "XiaoMiAirPurifier"
            if contentDict["name"] != nil {
                name = contentDict["name"] as! String
            }
            var avatarUrl = ""
            if contentDict["avatarUrl"] != nil {
                avatarUrl = contentDict["avatarUrl"] as! String
            }
            
            var deviceUri = ""
            if contentDict["uri"] != nil {
                deviceUri = contentDict["uri"] as! String
            }
            
            if deviceUri == MQTTClient.USER_EMAIL {
                return nil
            }
            
            if contentDict["attributes"] == nil {
                return nil
            }
            
            let attrs = contentDict["attributes"] as! [String:[String:Any]]
            var historyData:[String: [Double]] = [
                "Temperature": [14.0,13.0,54.0,62.0,12.5,4.5,7.6,55.5],
                "Humidity": [14.1,23.3,34.5,66.3,22.4,44.6,73.5,5.9],
            ]
            if contentDict["history"] != nil && contentDict["history"] is [String: [Double]]{
                historyData = contentDict["history"] as! [String: [Double]]
            }
            var location = ["longitude":0.0, "latitude": 0.0]
            if contentDict["location"] != nil && contentDict["location"] is [String: Double] {
                location = contentDict["location"] as! [String:Double]
            }
            
            for (index, device) in self.devices.enumerated() {
                if device.uri == deviceUri && device.context == context {
                    self.devices[index].originObject = contentDict
                    self.devices[index].loadAttrs(attrs: attrs)
                    self.devices[index].loadHistory(history: historyData)
                    self.devices[index].setDeviceRegion(latitude: location["latitude"]!, longitude: location["longitude"]!)
                    return nil
                }
            }
            //            //new device
            let newDevice = UDODevice(uri: deviceUri, name: name, context: context, avatarUrl: avatarUrl)
            newDevice.originObject = contentDict
            newDevice.loadAttrs(attrs: attrs)
            newDevice.loadHistory(history: historyData)
            newDevice.setDeviceRegion(latitude: location["latitude"]!, longitude: location["longitude"]!)
            return newDevice
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func parseAirPurifierFromHass(messageJSON: JSON)->UDODevice? {
        let payload = messageJSON["payload"].dictionaryObject ?? [:]
        let context = messageJSON["context"].stringValue
        let name = "XiaoMiAirPurifier"
        
        var avatarUrl = ""
        if payload["avatarUrl"] != nil && payload["avatarUrl"] is String {
            avatarUrl = payload["avatarUrl"] as! String
        }
        
        var deviceUri = ""
        if payload["uri"] != nil && payload["uri"] is String {
            deviceUri = payload["uri"] as! String
        }
        
        let historyData:[String: [Double]] = [
            "Temperature": [14.0,13.0,54.0,62.0,12.5,4.5,7.6,55.5],
            "Humidity": [14.1,23.3,34.5,66.3,22.4,44.6,73.5,5.9],
        ]
        
        var location = ["longitude":0.0, "latitude": 0.0]
        if payload["location"] != nil && payload["location"] is [String: Double] {
            location = payload["location"] as! [String:Double]
        }
        
        if deviceUri == MQTTClient.USER_EMAIL {
            return nil
        }
        
        if payload["attributes"] == nil {
            return nil
        }
        
        var attrs:[String:[String: Any]] = [:]
        attrs["state"] = ["category":"boolean", "editable": true]
        let state = payload["state"] as? String ?? "off"
        if state == "off" {
            attrs["state"]!["value"] = false
        } else {
            attrs["state"]!["value"] = true
        }
        
//        for name in ["led_brightness", "percentage_step", "filter_life_remaining", "filter_hours_used", "purify_volume", "average_aqi", "supported_features", "motor_speed", "temperature", "aqi", "humidity"] {
//            attrs[name] = ["category": "numerical", "value": messageJSON["payload"]["attributes"][name].doubleValue]
//        }
        
        for name in ["extra_features", "use_time", "supported_features"] {
            attrs[name] = ["category": "numerical", "value": messageJSON["payload"]["attributes"][name].doubleValue]
        }
        attrs["temperature"] = ["category": "numerical", "value":23.5]
        attrs["humidity"] = ["category": "numerical", "value":23.5]
        
        for name in ["friendly_name", "button_pressed"] {
            attrs[name] = ["category": "text", "value": messageJSON["payload"]["attributes"][name].stringValue]
        }
        
        for name in ["turbo_mode_supported"] {
            attrs[name] = ["category":"boolean", "editable":false, "value":messageJSON["payload"]["attributes"][name].boolValue]
        }
        
        attrs["preset_mode"] = ["category":"enum", "editable": false, "options":[
            "option1": "Auto",
            "option2": "Silent",
            "option3": "Favorite",
            "option4": "Idle"
        ], "value":messageJSON["payload"]["attributes"]["speed"].stringValue]
        
        
        
        for (index, device) in self.devices.enumerated() {
            if device.uri == deviceUri && device.context == context {
                self.devices[index].originObject = payload
                // load attrs
                self.devices[index].loadAttrs(attrs: attrs)
                self.devices[index].loadHistory(history: historyData)
                self.devices[index].setDeviceRegion(latitude: location["latitude"]!, longitude: location["longitude"]!)
                return nil
            }
        }
        
        let newDevice = UDODevice(uri: deviceUri, name: name, context: context, avatarUrl: avatarUrl)
        newDevice.isHass = true
        newDevice.loadAttrs(attrs: attrs)
        newDevice.loadHistory(history: historyData)
        newDevice.setDeviceRegion(latitude: location["latitude"]!, longitude: location["longitude"]!)
        newDevice.originObject = payload
        
        return newDevice
    }
    
    
}

extension DataManager: MessageRecevieDelegate {
    func didReceiveMessage(message: CocoaMQTTMessage) {
        print("Recevie Message from MQTT")
        let messageJSON = JSON(message.string!.data(using: .utf8)!)
        let topic = message.topic
        if topic == "topic/register" {
            let source = messageJSON["source"].string ?? ""
            let destination = messageJSON["destination"].string ?? ""
            if source == "backend" && destination == MQTTClient.USER_EMAIL {
                let newContext = messageJSON["context"].string ?? ""
                if newContext != "" {
                    if !self.contexts.contains(newContext) {
                        self.contexts.append(newContext)
                        _ = MQTTClient.shared.setUpMQTT()
                        notifyContextChange(newContext: newContext)
                    }
                }
            }
        } else {
            print("Receive from topic: \(topic)")
            let source = messageJSON["source"].string ?? ""
            let destination = messageJSON["destination"].string ?? ""
            let context = messageJSON["context"].string ?? ""
            if !self.contexts.contains(context) {
                return
            }
            if source != MQTTClient.USER_EMAIL {
                // not a message send from myself
                if destination == "all" {
                    // parse the device from the message payload
                    let category = messageJSON["category"].string ?? ""
                    if category == "update" {
                        let payload = messageJSON["payload"].rawString() ?? ""
                        print("Get payload:\(payload)")
                        if payload != "" {
                            // air purifier from hass
                            if messageJSON["payload"]["entity_id"].exists() {
                                let newDevice = parseAirPurifierFromHass(messageJSON: messageJSON)
                                if let newDevice = newDevice {
                                    print("Will append new device:\(newDevice)")
                                    self.devices.append(newDevice)
                                    self.notifyDeviceFound(device: newDevice)
                                }
                                return
                            }
                            // other device
                            let data = payload.data(using: .utf8) ?? Data()
                            let newDevice = parseUDODevice(data: data, context: context)
                            if let newDevice = newDevice {
                                print("Will append new device:\(newDevice)")
                                self.devices.append(newDevice)
                                self.notifyDeviceFound(device: newDevice)
                            }
                        }
                    }
                    
                    if category == "delete" {
                        print("Try to delete a device")
                        let payload = messageJSON["payload"].rawString() ?? ""
                        if payload != "" {
                            let uri = messageJSON["payload"]["uri"].string ?? ""
                            if uri != "" {
                                var deviceIndex = -1
                                for (index,device) in self.devices.enumerated() {
                                    if device.uri == uri && device.context == context {
                                        print("Find the device:\(index)")
                                        deviceIndex = index
                                        break
                                    }
                                }
                                if deviceIndex != -1 {
                                    self.devices.remove(at: deviceIndex)
                                    self.notifyDeviceRemoved(deviceUri: uri)
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
}

extension DataManager {
    // MARK: - Notification
    func notifyDeviceFound(device: UDODevice) {
        self.resourceFoundDelegate?.refresh()
        let content = UNMutableNotificationContent()
        content.title = "New device"
        content.body = "Find a new udo device in context:\(device.context)"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        print("Send notification")
        self.userNotificationCenter.add(request) {
            error in
            if let error = error {
                print("Notification Error: \(error.localizedDescription)")
            }
        }
    }
    
    func notifyDeviceRemoved(deviceUri: String) {
        let content = UNMutableNotificationContent()
        content.title = "Remove device"
        content.body = "Remove device: \(deviceUri)"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        print("Send notification")
        self.userNotificationCenter.add(request) {
            error in
            if let error = error {
                print("Notification Error: \(error.localizedDescription)")
            }
        }
    }
    
    func notifyContextChange(newContext: String) {
        self.contextFoundDelegate?.refresh()
        _ = MQTTClient.shared.setUpMQTT()
        let content = UNMutableNotificationContent()
        content.title = "Enter new context"
        content.body = "Enter new context: \(newContext)"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        print("Send notification")
        self.userNotificationCenter.add(request) {
            error in
            if let error = error {
                print("Notification Error: \(error.localizedDescription)")
            }
        }
        
    }
}
