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
    let location: [String : Float64]
    let available: Bool
    let avatarUrl: String
    let uri: String
}

class UserViewController: UIViewController {

    @IBOutlet weak var theContainer: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var userView = UserStatusView()
    let locationManager = CLLocationManager()
    var timer: Timer?
    var isAvailable: Bool = false
    
    let avatarURL = "E6FF994B62089DCFFDFEF286925D939144550C45DBEDF7491AAE2E47C464EF40211827BABD90D705F2C23F8A6E5B5AC88548D7597DE1D6F19238A5B37C18616A"
    
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
    }
    
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    func makeUserStatusPayload()->[String: Any] {
        let name = self.userView.userName
        let email = self.userView.userEmail
        var coordinate = CLLocationCoordinate2D()
        if self.isAvailable {
            coordinate = self.mapView.userLocation.coordinate
        }
        let available = self.isAvailable
        let location = ["longitude": coordinate.longitude, "latitude": coordinate.latitude ]
        let userStatus:[String: Any] = [
            "name": name,
            "uri" : email,
            "location": location,
            "available": available,
            "avatarUrl": avatarURL
        ]
        return userStatus
    }
    
    func startTimer() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true){
                timer in
                DispatchQueue.global().async {
                    // MARK:- TODO: check whether the application context is empty
                    // if the application context is empty, publish to register and request an application context.
                    // else publish to application context about the user status.
                    let payload = self.makeUserStatusPayload()
                    if DataManager.shared.contexts.count == 0 {
                        _ = MQTTClient.shared.publishToRegister(payload: payload, destination: MQTTClient.USER_EMAIL)
                    } else {
                        for context in DataManager.shared.contexts {
                            _ = MQTTClient.shared.publishToApplicationContext(payload: payload, destination: MQTTClient.USER_EMAIL, context: context)
                        }
                    }              
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
