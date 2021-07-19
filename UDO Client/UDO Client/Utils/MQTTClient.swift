//
//  MQTTClient.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/8.
//

import UIKit
import CocoaMQTT

protocol MessageRecevieDelegate:AnyObject {
    func didReceiveMessage(message: CocoaMQTTMessage)
}



struct MQTTConfiguration : Codable {
    let host:String
    let port: UInt16
}

class MQTTClient: NSObject {
    static var USER_EMAIL = ""
    static var BROKER_HOST = ""
    static var BROKER_PORT:UInt16 = 1883
    static let clientID = "cn.edu.nju.udo.iOSClient-" + (UIDevice.current.identifierForVendor?.uuidString)!
    var client: CocoaMQTT?
    weak var delegate: MessageRecevieDelegate?
    
    static let LOGMQTT_HOST = "broker.emqx.io"
    static let LOGMQTT_PORT:UInt16 = 1883
    static let logClient = CocoaMQTT(clientID: clientID, host: LOGMQTT_HOST, port: LOGMQTT_PORT)
    
    private override init() {
        super.init()
        let mqttConfiguration = self.loadMQTTConfiguration()
        if let mqttConfiguration = mqttConfiguration {
            MQTTClient.BROKER_HOST = mqttConfiguration.host
            MQTTClient.BROKER_PORT = mqttConfiguration.port
        }
        _ = MQTTClient.logClient.connect()
    }
    
    static var shared: MQTTClient = MQTTClient()
    
    func setUpMQTT()->Bool {
        if MQTTClient.BROKER_HOST == "" {
            print("Can not connect to MQTT Service")
            return false
        }
        if let previousClient = self.client {
            previousClient.disconnect()
        }
        self.client = CocoaMQTT(clientID: MQTTClient.clientID, host: MQTTClient.BROKER_HOST, port: MQTTClient.BROKER_PORT)
        self.client?.delegate = self
        self.client?.username = "udo-user"
        self.client?.password = "123456"
        self.client?.willMessage = CocoaMQTTMessage(topic: "/will ", string: "offline")
        self.client?.keepAlive = 60
        let connected = self.client?.connect()
        
        if let connected = connected {
            if connected {
                self.saveMQTTConfiguration()
            }
            return connected
        }
        return false
    }
    
    func connectState() -> CocoaMQTTConnState? {
        return self.client?.connState
    }
    
    func publishToRegister(payload: [String: Any], destination:String)->Int? {
        // MARK: - TODO: publish to register
        var message:[String: Any] = [:]
        message["source"] = MQTTClient.USER_EMAIL
        message["destination"] = destination
        message["category"] = "update"
        message["context"] = ""
        message["payload"] = payload
        let jsonObject = JSON(message)
        let jsonStr = jsonObject.rawString()!
        return self.client?.publish("topic/register", withString: jsonStr)
    }
    
    func publishToApplicationContext(payload: [String: Any], destination:String, context:String)->Int? {
        // MARK: - TODO: publish to application context
        var message:[String: Any] = [:]
        message["source"] = MQTTClient.USER_EMAIL
        message["destination"] = destination
        message["category"] = "update"
        message["context"] = context
        message["payload"] = payload
        let jsonObject = JSON(message)
        let jsonStr = jsonObject.rawString()!
        return self.client?.publish("topic/" + context, withString: jsonStr)
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
            let mqttConfiguration = MQTTConfiguration(host: MQTTClient.BROKER_HOST, port: MQTTClient.BROKER_PORT)
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

extension MQTTClient: CocoaMQTTDelegate {
    
    // These two methods are all we care about for now.
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        var topicLists:[(String, CocoaMQTTQoS)] = [("topic/register", .qos0),]
        for context in DataManager.shared.contexts {
            topicLists.append(("topic/" + context, .qos0))
        }
        self.client?.subscribe(topicLists)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        self.delegate?.didReceiveMessage(message: message)
    }
    
    // Other methods
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT did publish message \(message)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("MQTT did publish ack \(id) ")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("MQTT did unsubscribe topics: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
//        print("MQTT did ping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
//        print("MQTT did pong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("MQTT did disconnect")
        if let err = err {
            print("Error: \(err.localizedDescription)")
        } else {
            return 
        }
    }
    
    
    
    
    
    
    
    
    
}
