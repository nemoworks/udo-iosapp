//
//  UserViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/3.
//

import UIKit
import SwiftUI

class UserViewController: UIViewController {

    @IBOutlet weak var theContainer: UIView!
    
    let userView = UserStatusView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let childView = UIHostingController(rootView: self.userView)
        childView.view.frame = theContainer.bounds
        theContainer.addSubview(childView.view)
        childView.didMove(toParent: self)
        
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
