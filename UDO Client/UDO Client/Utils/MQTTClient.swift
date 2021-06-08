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
    let BROKER_HOST = "test.mosquitto.org"
    let BROKER_PORT:UInt16 = 1883
    let clientID = "cn.edu.nju.udo.iOSClient"
    var client: CocoaMQTT?
    weak var delegate: MessageRecevieDelegate?
    
    override init() {
        super.init()
        setUpMQTT()
    }
    
    func setUpMQTT() {
        self.client = CocoaMQTT(clientID: self.clientID, host: self.BROKER_HOST, port: self.BROKER_PORT)
        self.client?.delegate = self
        self.client?.username = "test"
        self.client?.password = "test"
        self.client?.willMessage = CocoaMQTTWill(topic: "/will ", message: "offline")
        self.client?.keepAlive = 60
        _ = self.client?.connect()
        
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
    
    // Other methods for Delegate
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
    
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        print("MQTT Client subscribe topics \(topics)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("MQTT Client unsubscribe topic \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("MQTT Client did ping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT Client receive pong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("MQTT Client disconnect")
        if let err = err {
            print("Errror: \(err.localizedDescription)")
        } else {
            print("No error")
        }
    }
    
    
}
