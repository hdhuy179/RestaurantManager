//
//  ManageViewCell.swift
//  Firebase_demo
//
//  Created by Hoang Dinh Huy on 11/3/19.
//  Copyright © 2019 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class OrderManagerViewCell: UITableViewCell {
    
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var finishDishOrderButton: RaisedButton!
    @IBOutlet weak var vBound: UIView!

    weak var delegate: TableBillDetailViewController?
    
    var order: Order! {
        didSet {
            setupView()
        }
    }
    
    func setupView() {
//        self.vBound.layer.shadowColor = UIColor.black.cgColor
//        self.vBound.layer.shadowOffset = CGSize(width: 5, height: 5)
//        self.vBound.layer.shadow
//        self.vBound.layer.masksToBounds = false
//        self.vBound.clipsToBounds = false
        finishDishOrderButton.layer.cornerRadius = 4
        if let _ = order.dish?.tenmonan, let _ = order.dish?.dongia, order.soluong > 0, order.trangthai >= 0 {
            dishNameLabel.text = "\(order.dish?.tenmonan ?? "")\n\((order.dish?.dongia ?? 0).splittedByThousandUnits())"
            progressLabel.text = "\(order.soluong)" //\(order.served_amount!)/
            finishDishOrderButton.setTitle(order.getState(), for: .disabled)
            
            if order.trangthai != 2 {
                finishDishOrderButton.isEnabled = false
                finishDishOrderButton.backgroundColor = .systemGray
                finishDishOrderButton.setTitleColor(.lightGray, for: .disabled)
                if order.trangthai == 0 || order.trangthai == 1 {
                    finishDishOrderButton.backgroundColor = .systemOrange
                    finishDishOrderButton.setTitleColor(.white, for: .disabled)
                }
            } else {
                finishDishOrderButton.isEnabled = true
                finishDishOrderButton.backgroundColor = .systemGreen
                finishDishOrderButton.setTitle(order.getState(forNextState: true), for: .normal)
            }
        }
    }
    
    @IBAction func handleFinishDishOrder(_ sender: Any) {
        order.trangthai = 3
        order.updateOrder(forOrder: order) { (error) in
            if error != nil {
                print(error ?? "")
            }
        }
        delegate?.fetchBillData()
    }
}
