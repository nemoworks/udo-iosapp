//
//  ContextMenuViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/20.
//

import UIKit

class ContextMenuViewController: UIViewController {
    
    var context: String = ""
    @IBOutlet weak var resourceButton: UIButton!
    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resourceButton.layer.cornerRadius = 7.0
        resourceButton.clipsToBounds = true
        taskButton.layer.cornerRadius = 7.0
        taskButton.clipsToBounds = true
        historyButton.layer.cornerRadius = 7.0
        historyButton.clipsToBounds = true
        quitButton.layer.cornerRadius = 7.0
        quitButton.clipsToBounds = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func quitContext(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resourceSegue" {
            let vc = segue.destination as! DeviceViewController
            vc.context = self.context
            vc.devices = DataManager.shared.getDevicesByContext(context: self.context)
            vc.title = "\(self.context)/Resource"
        }
        
        if segue.identifier == "taskSegue" {
            let vc = segue.destination as! TaskViewController
            vc.context = self.context
            vc.devices = DataManager.shared.getDevicesByContext(context:self.context)
            vc.title = "\(self.context)/Task"
        }
        
    }
    
}
