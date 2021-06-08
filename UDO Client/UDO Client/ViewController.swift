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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.mqttClient.delegate = self
    }

}

extension ViewController: MessageRecevieDelegate {
    func didReceiveMessage(message: CocoaMQTTMessage) {
        print("Recevie Message from MQTT: \(message.string!)")
        self.msgLabel.text = message.string!
    }
}

