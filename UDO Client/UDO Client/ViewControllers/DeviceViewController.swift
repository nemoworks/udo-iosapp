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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deviceDetail" {
            let vc = segue.destination as! DeviceDetailViewController
            let cell = sender as! DeviceTableViewCell
            let index = self.deviceTableView.indexPath(for: cell)!.row
            vc.device = self.devices[index]
        }
    }
    
    
    // if the data represents a new device, return the new device object
    // else return nil
    func parseUDODevice(data: Data)->UDODevice? {
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
            let newDevice = UDODevice(uri: deviceUri, name: name, avatarUrl: avatarUrl)
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


extension DeviceViewController: MessageRecevieDelegate {
    // MARK: - Receive Message
    // validate where the message come from
    func didReceiveMessage(message: CocoaMQTTMessage) {
        print("Recevie Message from MQTT")
        let messageJSON = JSON(message.string!.data(using: .utf8)!)
        let topic = message.topic
        if topic == "topic/register" {
            let source = messageJSON["source"].string ?? ""
            let destination = messageJSON["destination"].string ?? ""
            if source == "backend" && destination == MQTTClient.USER_EMAIL {
                let newContext = messageJSON["context"].string ?? ""
                MQTTClient.CURRENT_APPLICATION_CONTEXT = newContext
                _ = MQTTClient.shared.setUpMQTT()
                notifyContextChange(newContext: newContext)
            }
        } else {
            print("Receive from topic: \(topic)")
            let source = messageJSON["source"].string ?? ""
            let destination = messageJSON["destination"].string ?? ""
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
                            let newDevice = parseUDODevice(data: data)
                            if let newDevice = newDevice {
                                self.notifyDeviceFound(device: newDevice)
                                self.devices.append(newDevice)
                            }
                            self.deviceTableView.reloadData()
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
                                    if device.uri == uri {
                                        print("Find the device:\(index)")
                                        deviceIndex = index
                                        break
                                    }
                                }
                                if deviceIndex != -1 {
                                    self.devices.remove(at: deviceIndex)
                                    self.notifyDeviceRemoved(deviceUri: uri)
                                    self.deviceTableView.reloadData()
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
}

extension DeviceViewController {
    // MARK: - Notification
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
        let content = UNMutableNotificationContent()
        content.title = "Context change"
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

// MARK: - TableView Delegate
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

