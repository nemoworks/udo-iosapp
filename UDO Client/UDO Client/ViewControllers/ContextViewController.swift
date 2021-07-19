//
//  ContextViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/19.
//

import UIKit

class ContextViewController: UIViewController {

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
        if segue.identifier == "devicesSegue" {
            let cell = sender as! ContextTableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let index = indexPath!.row
            let context = DataManager.shared.contexts[index]
            let vc = segue.destination as! DeviceViewController
            vc.context = context
            vc.title = "Context/" + context
        }
    }
    
}

extension ContextViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.contexts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contextCell") as! ContextTableViewCell
        let index = indexPath.row
        let context = DataManager.shared.contexts[index]
        cell.contextName.text = context
        let image = UIImage(named: "context")
        cell.contextImage.image = image
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
}

extension ContextViewController: OnMessageDelegate {
    func refresh() {
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }
}
