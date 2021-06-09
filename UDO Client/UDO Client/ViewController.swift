//
//  ViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/8.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController {
    @IBOutlet weak var deviceTableView: UITableView!
    
    let mqttClient = MQTTClient()
    var devices: [Device] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.mqttClient.delegate = self
        self.deviceTableView.delegate = self
        self.deviceTableView.dataSource = self
    }
    
    

}

extension ViewController: MessageRecevieDelegate {
    func didReceiveMessage(message: CocoaMQTTMessage) {
        print("Recevie Message from MQTT")
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
            self.deviceTableView.reloadData()
            // TODO:- commit a notification
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell") as! DeviceTableViewCell
        
        let index = indexPath.row
        let device = self.devices[index]
        cell.deviceName.text = device.deviceName
        cell.deviceDescription.text = device.description
        let image = UIImage(named: "air-purifier")
        cell.deviceImage.image = image
        return cell
    }
    
    
}
