//
//  MQTTClient.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/8.
//

import UIKit
import MQTTNIO
import NIO


protocol MessageRecevieDelegate:AnyObject {
    func didReceiveMessage(message: String)
}



struct MQTTConfiguration : Codable {
    let host:String
    let port: UInt16
}

class UDOMQTTClient: NSObject {
    static var USER_EMAIL = ""
    static var BROKER_HOST = ""
    static var BROKER_PORT:UInt16 = 1883
    static let clientID = "cn.edu.nju.udo.iOSClient-" + (UIDevice.current.identifierForVendor?.uuidString)!
    var client: MQTTClient?
    weak var delegate: MessageRecevieDelegate?
    
    static let LOGMQTT_HOST = "broker.emqx.io"
    static let LOGMQTT_PORT:UInt16 = 1883
    static let logClient = CocoaMQTT(clientID: clientID, host: LOGMQTT_HOST, port: LOGMQTT_PORT)
    static let logClient = MQTTClient(
        host: LOGMQTT_HOST,
        port: 1883,
        identifier: clientID,
        eventLoopGroupProvider: .createNew)
    
    
    private override init() {
        super.init()
        let mqttConfiguration = self.loadMQTTConfiguration()
        if let mqttConfiguration = mqttConfiguration {
            UDOMQTTClient.BROKER_HOST = mqttConfiguration.host
            UDOMQTTClient.BROKER_PORT = mqttConfiguration.port
        }
        try UDOMQTTClient.logClient.connect().wait()
    }
    
    static var shared: UDOMQTTClient = UDOMQTTClient()
    
    func setUpMQTT()->Bool {
        if UDOMQTTClient.BROKER_HOST == "" {
            print("Can not connect to MQTT Service")
            return false
        }
        if let previousClient = self.client {
            previousClient.disconnect()
        }
        
        var clientConfiguration = MQTTClient.Configuration()
        clientConfiguration.userName = "udo-user"
        clientConfiguration.password = "123456"
        clientConfiguration.keepAliveInterval = 60
        
        
        self.client = MQTTClient(host: UDOMQTTClient.BROKER_HOST, port: UDOMQTTClient.BROKER_PORT, identifier: UDOMQTTClient.clientID, eventLoopGroupProvider: .createNew, configuration: clientConfiguration)
        
        let connected = try self.client?.connect().wait()
        
        if let connected = connected {
            if connected {
                self.saveMQTTConfiguration()
                // MARK: - Subscribe topics
                var topicList:[MQTTSubscribeInfo] = [MQTTSubscribeInfo(topicFilter: "topic/register", qos: .atLeastOnce)]
                for context in DataManager.shared.contexts {
                    topicLists.append(MQTTSubscribeInfo(topicFilter: "topic/" + context, qos: .atLeastOnce))
                }
                
                try self.client?.subscribe(to: topicList).wait()
                self.client?.addPublishListener(named: "Listener"){ result in
                    switch result {
                    case .success(let publish):
                        var buffer = publish.payload
                        let payloadString = buffer.readString(length: buffer.readableBytes)
                        self.delegate?.didReceiveMessage(message: payloadString)
                    case .failure(let error):
                        print("Error while receiving publish event \(error.localizedDescription)")
                        
                    }
                    
                }
                
            }
            return connected
        }
        return false
    }
    
    func connectState() -> Bool {
        var isActive = self.client?.isActive() ?? false
        return isActive
    }
    
    func publishToRegister(payload: [String: Any], destination:String){
        // MARK: - TODO: publish to register
        var message:[String: Any] = [:]
        message["source"] = UDOMQTTClient.USER_EMAIL
        message["destination"] = destination
        message["category"] = "update"
        message["context"] = ""
        message["payload"] = payload
        let jsonObject = JSON(message)
        let jsonStr = jsonObject.rawString()!
        let message = ByteBufferAllocator().buffer(string: jsonStr)
        try UDOMQTTClient.logClient.publish(to: "topic/log", payload: message, qos: .atMostOnce).wait()
        try self.client?.publish(to: "topic/register", payload: message, qos: .exactlyOnce).wait()
    }
    
    func publishToApplicationContext(payload: [String: Any], destination:String, context:String)->Int? {
        // MARK: - TODO: publish to application context
        var message:[String: Any] = [:]
        message["source"] = UDOMQTTClient.USER_EMAIL
        message["destination"] = destination
        message["category"] = "update"
        message["context"] = context
        message["payload"] = payload
        let jsonObject = JSON(message)
        let jsonStr = jsonObject.rawString()!
        let message = ByteBufferAllocator().buffer(string: jsonStr)
        
        try UDOMQTTClient.logClient.publish(to: "topic/log", payload: message, qos: .atMostOnce).wait()
        try self.client?.publish(to: "topic/"+context, payload: message, qos: .exactlyOnce).wait()
    }
    
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("MQTT.plist")
    }
    
    func saveMQTTConfiguration() {
        let encoder = PropertyListEncoder()
        do {
            let mqttConfiguration = MQTTConfiguration(host: UDOMQTTClient.BROKER_HOST, port: UDOMQTTClient.BROKER_PORT)
            let data = try encoder.encode(mqttConfiguration)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            print("Error encoding: \(error.localizedDescription)")
        }
    }
    
    func loadMQTTConfiguration() -> MQTTConfiguration? {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                let mqttConfiguration = try decoder.decode(MQTTConfiguration.self, from: data)
                return mqttConfiguration
            } catch {
                print("Error decoding: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
}


    
    
    
    
    
    
    
