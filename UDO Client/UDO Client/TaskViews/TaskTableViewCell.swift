//
//  TaskTableViewCell.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/20.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceUri: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundColor = .clear // very important
        layer.masksToBounds = false
        layer.shadowOpacity = 0.23
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor

        // add corner radius on `contentView`
        contentView.backgroundColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        contentView.layer.cornerRadius = 8
        // Configure the view for the selected state
    }

}
