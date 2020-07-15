//
//  ManagerDataTableViewCell.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/31/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class ManagerDataTableViewCell: UITableViewCell {

    @IBOutlet weak var lb1: UILabel!
    @IBOutlet weak var lb2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lb1.text = ""
        lb2.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
