//
//  CartViewCell.swift
//  Firebase_demo
//
//  Created by Hoang Dinh Huy on 10/25/19.
//  Copyright © 2019 Hoang Dinh Huy. All rights reserved.
//

import UIKit

final class CartViewCell: UITableViewCell {
    
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var dishPriceLabel: UILabel!
    @IBOutlet weak var dishAmountLabel: UILabel!
    @IBOutlet weak var txtNote: TextField!
    
    weak var delegate: OrderViewControllerDelegate?
    
    var order: Order! {
        didSet {
            setupView()
        }
    }
    
    private var amount: Int = 0
    
    func setupView() {
        
        dishNameLabel.text = order.dish?.tenmonan
        if let price = order.dish?.dongia {
            dishPriceLabel.text = price.splittedByThousandUnits()
        }
        amount = order.soluong
        dishAmountLabel.text = String(order.soluong)
//        txtNote.delegate = self
        txtNote.isEnabled = false
    }
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        if amount >= 99 {
            return
        }
        amount += 1
        dishAmountLabel.text = String(amount)
        delegate?.changeOrderAmount(dish: order.dish!, amount: amount)
    }
    
    @IBAction func minusButtonTapped(_ sender: Any) {
        if amount > 0 {
            amount -= 1
        }
        dishAmountLabel.text = String(amount)
        delegate?.changeOrderAmount(dish: order.dish!, amount: amount)
    }
}
extension CartViewCell: UITextFieldDelegate {
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        delegate?.changeOrderAmount(dish: order.dish!, amount: amount)
//    }
}
