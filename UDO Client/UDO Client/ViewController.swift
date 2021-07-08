//
//  ViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/8.
//

import UIKit
import CocoaMQTT
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet weak var deviceTableView: UITableView!
    
    var devices: [UDODevice] = [
    
        
    ]
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let connected = MQTTClient.shared.setUpMQTT()
        if !connected {
            let alert = UIAlertController(title: "Service unavailable", message: "Can not connect to MQTT Service", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        MQTTClient.shared.delegate = self
        self.deviceTableView.delegate = self
        self.deviceTableView.dataSource = self
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.deviceTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    func notifyDeviceFound(device: UDODevice) {
        let content = UNMutableNotificationContent()
        content.title = "New device"
        content.body = "Find a new udo device"
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
    
    func reconnectToMQTT() {
        let connected = MQTTClient.shared.setUpMQTT()
        if !connected {
            let alert = UIAlertController(title: "Service unavailable", message: "Can not connect to MQTT Service", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deviceDetail" {
            let vc = segue.destination as! DeviceDetailViewController
            let cell = sender as! DeviceTableViewCell
            let index = self.deviceTableView.indexPath(for: cell)!.row
            vc.device = self.devices[index]
        }
    }

}

extension ViewController: MessageRecevieDelegate {
    func didReceiveMessage(message: CocoaMQTTMessage) {
        print("Recevie Message from MQTT")
        do {
            let contentDict = try JSONSerialization.jsonObject(with: message.string!.data(using: .utf8)!, options: []) as! [String:Any]
            print("Parse to dictionary:  \(contentDict)")
            let sender = contentDict["sender"]
            if let sender = sender as? String {
                if sender != "server" {
                    return
                }
            } else {
                return
            }
            let id = contentDict["id"] as! UInt64
            let name = contentDict["name"] as! String
            let attrs = contentDict["attributes"] as! [String:[Any]]
            let historyData = contentDict["history"] as! [String: [Double]]
            let location = contentDict["location"] as! [String: Double]
            for (index, device) in self.devices.enumerated() {
                if device.deviceID == id {
                    self.devices[index].loadAttrs(attrs: attrs)
                    self.devices[index].loadHistory(history: historyData)
                    self.devices[index].setDeviceRegion(latitude: location["latitude"]!, longitude: location["longitude"]!)
                    return
                }
            }
            //new device
            let newDevice = UDODevice(id: id, name: name)
            print(newDevice)
            newDevice.loadAttrs(attrs: attrs)
            newDevice.loadHistory(history: historyData)
            newDevice.setDeviceRegion(latitude: location["latitude"]!, longitude: location["longitude"]!)
            self.notifyDeviceFound(device: newDevice)
            self.devices.append(newDevice)
            self.deviceTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
        let verticalPadding: CGFloat = 8
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 10    //if you want round edges
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height:cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
    
    
}

