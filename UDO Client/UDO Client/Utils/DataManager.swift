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
        return []
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
            
            if contentDict["attributes"] == nil {
                return nil
            }
            
            let attrs = contentDict["attributes"] as! [String:[String:Any]]
            var historyData:[String: [Double]] = [:]
            if contentDict["history"] != nil && contentDict["history"] is [String: [Double]]{
                historyData = contentDict["history"] as! [String: [Double]]
            }
            var location = ["longitude":0.0, "latitude": 0.0]
            if contentDict["location"] != nil && contentDict["location"] is [String: Double] {
                location = contentDict["location"] as! [String:Double]
            }
            
            for (index, device) in self.devices.enumerated() {
                if device.uri == deviceUri {
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
                            let data = payload.data(using: .utf8) ?? Data()
                            let newDevice = parseUDODevice(data: data, context: context)
                            if let newDevice = newDevice {
                                self.notifyDeviceFound(device: newDevice)
                                self.devices.append(newDevice)
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
