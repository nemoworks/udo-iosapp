//
//  TaskViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/20.
//

import UIKit
import SwiftUI

class TaskViewController: UIViewController {

    @IBOutlet weak var theContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let taskView = TaskView()
        let childView = UIHostingController(rootView: taskView)
        childView.view.frame = self.theContainer.bounds
        self.theContainer.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
    
    @IBAction func done(_ sender: Any) {
        let alertController = UIAlertController(title: "Info", message: "upload done", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        
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
