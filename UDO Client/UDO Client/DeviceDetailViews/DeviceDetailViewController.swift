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
    func sendDeviceStatus(deviceStatus: DeviceStatus)->Int? {
        print("Will send device status: \(deviceStatus) to \(self.device?.uri ?? "123")")
        let deviceOriginObject:[String:Any] = (self.device?.originObject)!
        let enumStatus:[String:String] = deviceStatus.enum_status
        let booleanStatus:[String:Bool] = deviceStatus.boolean_status
        var jsonObject = JSON(deviceOriginObject)
        
        for e1 in enumStatus {
            jsonObject["attributes"][e1.key]["value"].stringValue = e1.value
            for e2 in self.device!.enumAttrs {
                if e1.key == e2.name {
                    e2.currentOption = e1.value
                }
            }
        }
        for b1 in booleanStatus {
            jsonObject["attributes"][b1.key]["value"].boolValue = b1.value
            for b2 in self.device!.booleanAttrs {
                if b1.key == b2.name {
                    b2.on = b1.value
                }
            }
        }
        let payload = jsonObject.dictionaryObject!
        let sendFlag = MQTTClient.shared.publishToApplicationContext(payload: payload, destination: deviceStatus.uri)
        return sendFlag
    }
}
