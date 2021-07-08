//
//  DeviceDetailViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/10.
//

import UIKit
import SwiftUI
import MapKit

class DeviceDetailViewController: UIViewController {
    
    var device: UDODevice?
    @IBOutlet weak var theContainer: UIView!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        let childView = UIHostingController(rootView: DeviceDetailView(device: self.device!))
        addChild(childView)
        childView.view.frame = theContainer.bounds
        theContainer.addSubview(childView.view)
        childView.didMove(toParent: self)
        // set up mapView
        self.mapView.userTrackingMode = .follow
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = false
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
    }
    
    override var prefersHomeIndicatorAutoHidden:Bool{
        return true
    }
    

}
