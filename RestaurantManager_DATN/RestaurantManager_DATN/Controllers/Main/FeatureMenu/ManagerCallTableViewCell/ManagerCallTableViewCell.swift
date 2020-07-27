//
//  ManagerCallTableViewCell.swift
//  RestaurantManager_DATN
//
//  Created by HuyHoangDinh on 7/27/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class ManagerCallTableViewCell: UITableViewCell {

    @IBOutlet weak var lbDetail: UILabel!
    func configView(data: NhanVien) {
        lbDetail.text = "\(data.tennhanvien) - \(data.getPosition())"
    }
    
}
