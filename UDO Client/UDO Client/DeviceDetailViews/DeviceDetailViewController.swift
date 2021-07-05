//
//  DeviceDetailViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/10.
//

import UIKit
import SwiftUI

class DeviceDetailViewController: UIViewController {
    
    var device: UDODevice?
    @IBOutlet weak var theContainer: UIView!
    
    
    override func viewDidLoad() {
        let childView = UIHostingController(rootView: DeviceDetailView(device: self.device!))
        addChild(childView)
        childView.view.frame = theContainer.bounds
        theContainer.addSubview(childView.view)
        childView.didMove(toParent: self)
        // Do any additional setup after loading the view.
    }
    
    override var prefersHomeIndicatorAutoHidden:Bool{
        return true
    }
    

}
