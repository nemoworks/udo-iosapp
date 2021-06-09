//
//  ViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/8.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController {
    @IBOutlet weak var msgLabel: UILabel!
    
    let mqttClient = MQTTClient()
    
    var devices: [Device] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.mqttClient.delegate = self
    }
    
    

}

extension ViewController: MessageRecevieDelegate {
    func didReceiveMessage(message: CocoaMQTTMessage) {
        print("Recevie Message from MQTT")
        self.msgLabel.text = message.string!
        do {
            let contentDict = try JSONSerialization.jsonObject(with: message.string!.data(using: .utf8)!, options: []) as! [String:Any]
            print("Parse to dictionary:  \(contentDict)")
            let id = contentDict["id"] as! UInt64
            let name = contentDict["name"] as! String
            let newDevice = Device(id: id, name: name)
            print(newDevice)
            let attrs = contentDict["attributes"] as! [String:[Any]]
            newDevice.loadAttrs(attrs: attrs)
            self.devices.append(newDevice)
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

