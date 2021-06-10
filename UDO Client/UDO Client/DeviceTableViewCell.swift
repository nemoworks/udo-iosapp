//
//  DeviceTableViewCell.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/9.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var deviceDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
