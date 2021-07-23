//
//  TaskViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/20.
//

import UIKit

class TaskViewController: UIViewController {
    
    var context: String = ""
    @IBOutlet weak var taskTableView: UITableView!
    var devices: [UDODevice] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.taskTableView.delegate = self
        self.taskTableView.dataSource = self
        // Do any additional setup after loading the view.
        self.taskTableView.separatorStyle = .none
    }
    
    func loadData() {
        self.devices = DataManager.shared.getDevicesByContext(context: self.context)
        if self.isViewLoaded {
            self.taskTableView.reloadData()
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        if self.isViewLoaded {
            self.loadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deviceDetail" {
            let vc = segue.destination as! DeviceDetailViewController
            let cell = sender as! TaskTableViewCell
            let index = self.taskTableView.indexPath(for: cell)!.row
            vc.device = self.devices[index]
        }
    }
}

extension TaskViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskTableViewCell") as! TaskTableViewCell
        let index = indexPath.row
        cell.deviceUri.text = self.devices[index].uri
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
        let verticalPadding: CGFloat = 8
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 10    //if you want round edges
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height:cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}
