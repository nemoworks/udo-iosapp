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
    
    let userView = UserStatusView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let childView = UIHostingController(rootView: self.userView)
        childView.view.frame = theContainer.bounds
        theContainer.addSubview(childView.view)
        childView.didMove(toParent: self)
        // map view
        self.mapView.userTrackingMode = .follow
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = false
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        _ = MQTTClient.shared.publish(data: makeUserStatusPayload())
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    func makeUserStatusPayload()->Data {
        let name = self.userView.userName
        let id = self.userView.userID!
        let coordinate = self.mapView.userLocation.coordinate
        let available = self.userView.isAvailable
        
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

}
