//
//  ResourceViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/19.
//

import UIKit

class ResourceViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deviceDetail" {
            let vc = segue.destination as! DeviceDetailViewController
            let cell = sender as! ResourceTableViewCell
            let index = self.tableView.indexPath(for: cell)!.row
            vc.device = DataManager.shared.devices[index]
        }
    }

}

extension ResourceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resourceCell") as! ResourceTableViewCell
        let index = indexPath.row
        let device = DataManager.shared.devices[index]
        cell.resourceContext.text = device.context
        cell.resourceUri.text = device.uri
        var image = UIImage(named: "bus")
        if device.isHass {
            image = UIImage(named: "air-purifier")
        }
        cell.resourceImage.image = image
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
        return 160
    }
    
}

extension ResourceViewController: OnMessageDelegate {
    func refresh() {
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }
}
