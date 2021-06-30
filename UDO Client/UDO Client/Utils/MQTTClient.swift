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

class MQTTClient: NSObject {
    static var BROKER_HOST = ""
    static var BROKER_PORT:UInt16 = 1883
    let clientID = "cn.edu.nju.udo.iOSClient"
    var client: CocoaMQTT?
    weak var delegate: MessageRecevieDelegate?
    
    override init() {
        super.init()
    }
    
    func setUpMQTT()->Bool {
        if MQTTClient.BROKER_HOST == "" {
            print("Can not connect to MQTT Service")
            return false
        }
        self.client = CocoaMQTT(clientID: self.clientID, host: MQTTClient.BROKER_HOST, port: MQTTClient.BROKER_PORT)
        self.client?.delegate = self
        self.client?.username = "test"
        self.client?.password = "test"
        self.client?.willMessage = CocoaMQTTMessage(topic: "/will ", string: "offline")
        self.client?.keepAlive = 60
        let connected = self.client?.connect()
        return connected!
    }
    
}

extension MQTTClient: CocoaMQTTDelegate {
    
    // These two methods are all we care about for now.
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        self.client?.subscribe("topic/udo-test")
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
        print("MQTT did ping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT did pong")
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
