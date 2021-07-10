//
//  UserViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/3.
//

import UIKit
import SwiftUI
import MapKit

struct UserStatus: Codable {
    let name: String
    let sender: String
    let latitude: Double
    let longitude: Double
    let available: Bool
    
}

class UserViewController: UIViewController {

    @IBOutlet weak var theContainer: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var userView = UserStatusView()
    let locationManager = CLLocationManager()
    var timer: Timer?
    var isAvailable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.userView.delegate = self
        let childView = UIHostingController(rootView: self.userView)
        childView.view.frame = theContainer.bounds
        theContainer.addSubview(childView.view)
        childView.didMove(toParent: self)
        // map view
        self.mapView.userTrackingMode = .follow
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        self.startTimer()
    }
    
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    func makeUserStatusPayload()->Data {
        let name = self.userView.userName
        let id = self.userView.userID!
        var coordinate = self.mapView.userLocation.coordinate
        if !self.isAvailable {
            coordinate = CLLocationCoordinate2D()
        }
        let available = self.isAvailable
        
        let userStatus = UserStatus(name: name, sender: id, latitude: coordinate.latitude, longitude: coordinate.longitude, available: available )
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(userStatus)
            return data
        }catch {
            print("Encode error: \(error.localizedDescription)")
        }
        
        return Data()
    }
    
    func startTimer() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true){
                timer in
                DispatchQueue.global().async {
                    let payload = self.makeUserStatusPayload()
                    _ = MQTTClient.shared.publish(data: payload)
                }
            }
        }
    }
    
    func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    
}

extension UserViewController : UserStatusChangeDelegate {
    func changeAvaliable(to value: Bool) {
        print("Change value to \(value)")
        self.isAvailable = value
    }
}
