//
//  ViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/8.
//

import UIKit
import CocoaMQTT
import UserNotifications

class DeviceViewController: UIViewController {
    @IBOutlet weak var deviceTableView: UITableView!
    
    var devices: [UDODevice] = []
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let connected = MQTTClient.shared.setUpMQTT()
        if !connected{
            let alert = UIAlertController(title: "Service unavailable", message: "Can not connect to MQTT Service", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        self.deviceTableView.delegate = self
        self.deviceTableView.dataSource = self
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.deviceTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userEmail = MQTTClient.USER_EMAIL
        if userEmail == "" {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginViewController")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // if the data represents a new device, return the new device object
    // else return nil
    func parseUDODevice(data: Data)->UDODevice? {
        do {
            let contentDict = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
            print("Parse to dictionary:  \(contentDict)")
            
            var id = "1234567"
            if contentDict["id"] != nil {
                id = contentDict["id"] as! String
            }
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
                if device.deviceID == id {
                    self.devices[index].originObject = contentDict
                    self.devices[index].loadAttrs(attrs: attrs)
                    self.devices[index].loadHistory(history: historyData)
                    self.devices[index].setDeviceRegion(latitude: location["latitude"]!, longitude: location["longitude"]!)
                    return nil
                }
            }
//            //new device
            let newDevice = UDODevice(id: id, name: name, avatarUrl: avatarUrl, uri: deviceUri)
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deviceDetail" {
            let vc = segue.destination as! DeviceDetailViewController
            let cell = sender as! DeviceTableViewCell
            let index = self.deviceTableView.indexPath(for: cell)!.row
            vc.device = self.devices[index]
        }
    }

}

extension DeviceViewController: MessageRecevieDelegate {
    func didReceiveMessage(message: CocoaMQTTMessage) {
        print("Recevie Message from MQTT")
        let newDevice = self.parseUDODevice(data: message.string!.data(using: .utf8)!)
        if let newDevice = newDevice {
            self.notifyDeviceFound(device: newDevice)
            self.devices.append(newDevice)
        }
        self.deviceTableView.reloadData()
    }
}

extension DeviceViewController: UITableViewDelegate, UITableViewDataSource {
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

