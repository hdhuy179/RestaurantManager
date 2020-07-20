//
//  OrderTableViewCell.swift
//  
//
//  Created by Hoang Dinh Huy on 2/7/20.
//

import UIKit

class KitchenOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var lbDishName: UILabel!
    @IBOutlet weak var lbOrderAmount: UILabel!
    @IBOutlet weak var lbWaitTime: UILabel!
    @IBOutlet weak var btnFinish: RaisedButton!
    
    var order: Order?
    
    weak var delegate: KitchenViewController?
    
    func configView(order: Order, table: BanAn?) {
        
        self.order = order
        lbDishName.text = "\(order.dish?.tenmonan ?? "") (Bàn \(table?.sobanan ?? "nil") )"
        lbOrderAmount.text = String(order.soluong)
        lbWaitTime.text = ""
        if let ngaytao = order.ngaytao {
            let time = Int(Date().timeIntervalSince1970 - ngaytao.timeIntervalSince1970)
            lbWaitTime.text = "\(time/60)p"
            if time/60 >= 60 {
                lbWaitTime.text = "\(time/3600)g \((time%3600)/60)p"
            }
        }
        if order.trangthai > 1 || order.trangthai < 0 {
            btnFinish.isEnabled = false
            btnFinish.backgroundColor = .systemGray
            btnFinish.setTitle(order.getState(), for: .disabled)
        } else if order.trangthai >= 0 && order.trangthai < 2 {
            btnFinish.isEnabled = true
            btnFinish.backgroundColor = .systemGreen
            btnFinish.setTitle(order.getState(forNextState: true), for: .normal)
        }
    }
    
    @IBAction func btnFinishWasTapped(_ sender: Any) {
        
        if var order = order, order.trangthai >= 0{
            order.trangthai = order.trangthai + 1
//            order.ngaytao = Date()
            self.order = order
             btnFinish.isEnabled = false
            btnFinish.backgroundColor = .systemGray
            
            if order.trangthai > 1 || order.trangthai < 0 {
                btnFinish.setTitle(order.getState(), for: .disabled)
            } else if order.trangthai >= 0 && order.trangthai < 2 {
                btnFinish.setTitle(order.getState(forNextState: true), for: .disabled)
            }
            order.updateOrder(forOrder: order) { [weak self] error in
                self?.delegate?.fetchData()
            }
        }
    }
}
