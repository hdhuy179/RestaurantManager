//
//  TakeawayBillTableViewCell.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 2/9/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class BillTableViewCell: UITableViewCell {

    @IBOutlet weak var lbTotalPay: UILabel!
    @IBOutlet weak var lbStaffName: UILabel!
    @IBOutlet weak var lbCreateTime: UILabel!
    
    var bill: HoaDon? {
        didSet {
            setupView()
        }
    }
    
    func setupView() {
        lbTotalPay.text = bill?.getTotalPayment().splittedByThousandUnits() ?? ""
        lbStaffName.text = bill?.staff?.tennhanvien ?? ""
        lbCreateTime.text = String(bill?.ngaytao.convertToString(withDateFormat: "hh:MM:ss") ?? "")
    }
    
}
