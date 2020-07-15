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
    
    var order: Order? {
        didSet {
            setupView()
            fetchBillData()
        }
    }
    weak var delegate: KitchenViewController?
    
    func fetchBillData() {
        btnFinish.layer.cornerRadius = 5
        if let idhoadon = order?.idhoadon, let dish = order?.dish {
            HoaDon.fetchData(ofBillID: idhoadon) { [weak self](data, error) in
                if let idbanan = data?.idbanan {
                    BanAn.fetchData(ofID: idbanan) { (banan, error) in
                         self?.lbDishName.text = dish.tenmonan + " (Bàn " + (banan?.sobanan ?? "") + ")"
                        
                    }
                }
                
            }
        }
    }
    
    func setupView() {
        if let order = order, let dish = order.dish {
            lbDishName.text = dish.tenmonan
            lbOrderAmount.text = String(order.soluong)
            lbWaitTime.text = ""
            if let ngaytao = order.ngaytao, order.trangthai < 2 {
                let time = Int(Date().timeIntervalSince1970 - ngaytao.timeIntervalSince1970)
                lbWaitTime.text = "\(time/60)p"
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
    }
    
    @IBAction func btnFinishWasTapped(_ sender: Any) {
        
        if var order = order, order.trangthai >= 0{
            order.trangthai = order.trangthai + 1
//            order.ngaytao = Date()
            self.order = order
            order.updateOrder(forOrder: order) { [weak self] error in
                self?.delegate?.fetchAllTodayOrder()
            }
        }
    }
}
