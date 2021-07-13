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
        let childView = UIHostingController(rootView: DeviceDetailView(device: self.device!, vc: self))
        addChild(childView)
        childView.view.frame = theContainer.bounds
        theContainer.addSubview(childView.view)
        childView.didMove(toParent: self)
        // set up mapView
        self.mapView.delegate = self
        self.mapView.userTrackingMode = .follow
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        self.setupDevicePin()
        
    }
    
    override var prefersHomeIndicatorAutoHidden:Bool{
        return true
    }
    
    func setupDevicePin() {
        if let device = self.device {
            if let center = device.deviceLocation?.center {
                let devicePin = UDOMapAnnotation(deviceName: device.deviceName)
                devicePin.coordinate = center
                self.mapView.addAnnotation(devicePin)
            }
        }
    }

}


extension DeviceDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is UDOMapAnnotation) {
            return nil
        }
        
        let identifier = "udo-device"
        var annotationView =  mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        let udoAnnotation = annotation as! UDOMapAnnotation
        var imageName = UDOMapAnnotation.ImageByDeviceName[udoAnnotation.deviceName!]
        if imageName == nil {
            imageName = "air-purifier"
        }
        let image = UIImage(named: imageName!)
        annotationView!.image = imageWithImage(image: image!, scaledToSize: CGSize(width: 50, height: 50))
        return annotationView
    }
}

extension DeviceDetailViewController: DeviceStatusSendDelegate {
    func sendDeviceStatus(deviceStatus: DeviceStatus) {
        print("Will send device status: \(deviceStatus)")
        let deviceOriginObject:[String:Any] = (self.device?.originObject)!
        let enumStatus:[String:String] = deviceStatus.enum_status
        let booleanStatus:[String:Bool] = deviceStatus.boolean_status
        var jsonObject = JSON(deviceOriginObject)
        
        for e in enumStatus {
            jsonObject["attributes"][e.key]["value"].stringValue = e.value
        }
        for b in booleanStatus {
            jsonObject["attributes"][b.key]["value"].boolValue = b.value
        }
        
        let jsonStr = jsonObject.rawString()!
        
        
        
        
        let sendFlag = MQTTClient.shared.publish(str: jsonStr)
        
        if let sendFlag = sendFlag {
            if sendFlag != -1 {
                // send successfully
                let alert = UIAlertAction(title: "OK", style: .default, handler: nil)
                let alertController = UIAlertController(title: "Alert", message: "Send successfully", preferredStyle: .alert)
                alertController.addAction(alert)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    
}
