//
//  TableBillDetailViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 6/4/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class TableBillDetailViewController: UIViewController {

    @IBOutlet weak var bottomConstrainPaymentButton: NSLayoutConstraint!
    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    @IBOutlet weak var excessCashLabel: UILabel!
    @IBOutlet weak var guestMoneyTextField: UITextField!
    @IBOutlet weak var paymentButton: RaisedButton!
    @IBOutlet weak var btnOrderMore: RaisedButton!
    
    weak var delegate: RestaurantViewController?
    
    var table: BanAn?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addEndEditingTapGuesture()
        
        orderTableView.delegate = self
        orderTableView.dataSource = self
        
        orderTableView.register(UINib(nibName: "OrderManagerViewCell", bundle: nil), forCellReuseIdentifier: "OrderManagerViewCell")
        
        guestMoneyTextField.addTarget(self, action: #selector(changeGuestMoneyTextField(_:)), for: .editingChanged)
        
        lbTitle.text = "Bàn \(table?.sobanan ?? "")"
        excessCashLabel.text = ""
        table?.bill?.orderList = []
        
        paymentButton.isEnabled = false
        paymentButton.backgroundColor = .systemGray
        paymentButton.pulseColor = .white
        
        fetchBillData()
        if App.shared.staffInfo?.quyen != 1 && App.shared.staffInfo?.quyen != 2 && App.shared.staffInfo?.quyen != 3 {
            btnOrderMore.isEnabled = false
            btnOrderMore.setTitleColor(.lightGray, for: .normal)
        }
        if App.shared.staffInfo?.quyen != 1 && App.shared.staffInfo?.quyen != 2 {
            guestMoneyTextField.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.fetchData()
    }
    
    func fetchBillData() {
        if let id = table?.bill?.idhoadon {
            HoaDon.fetchData(ofBillID: id) { [weak self] bill, error in
                self?.table?.bill = bill
                
                self?.setupData()
            }
        }
    }
    
    func setupData() {
        orderTableView.reloadData()
        
        totalPaymentLabel.text = table?.bill?.getTotalPayment().splittedByThousandUnits()
        if table?.bill?.dathanhtoan != 0 {
            paymentButton.isEnabled = false
            paymentButton.backgroundColor = .systemGray
            guestMoneyTextField.isEnabled = false
        }
    }
    
    @objc func changeGuestMoneyTextField(_ textField: UITextField) {
       
        var guestMoney = textField.text ?? ""
        guestMoney.removeAll(where: { (char) -> Bool in
            return char == "."
        })
         guestMoneyTextField.text = Double(guestMoney)?.splittedByThousandUnits()
        if Double(guestMoney) ?? 0 >= table?.bill?.getTotalPayment() ?? 0 {
            paymentButton.isEnabled = true
            paymentButton.backgroundColor = .systemGreen
            let excessCash = Double(guestMoney)! - (table?.bill?.getTotalPayment() ?? 0)
            excessCashLabel.text = String(excessCash.splittedByThousandUnits())
        } else {
            excessCashLabel.text = ""
            paymentButton.isEnabled = false
            paymentButton.backgroundColor = .systemGray
        }
    }
    
    @objc override func keyboardWillShow(notification: NSNotification) {
        super.keyboardWillShow(notification: notification)
        if guestMoneyTextField.isEditing {
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.excessCashLabel.frame.origin.y)
//            }, completion: nil)
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                
                let keyboardHeight: CGFloat

                if #available(iOS 11.0, *) {
                    keyboardHeight = keyboardFrame.cgRectValue.height - view.safeAreaInsets.bottom
                } else {
                    keyboardHeight = keyboardFrame.cgRectValue.height
                }
                
                bottomConstrainPaymentButton.constant = -keyboardHeight + paymentButton.frame.height
            }
        }
    }
    @objc override func keyboardWillHide(notification: NSNotification) {
        super.keyboardWillHide(notification: notification)
        if guestMoneyTextField.isEditing {
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
//            }, completion: nil)
            bottomConstrainPaymentButton.constant = 0
        }
    }
    
    @IBAction func btnOrderMoreWasTapped(_ sender: Any) {
        let presentHandler = PresentHandler()
        presentHandler.presentMakeOrderVC(self, tableData: table)
    }
    
    @IBAction func btnPaymentWasTapped(_ sender: Any) {
        table?.bill?.dathanhtoan = 1
        
        for index in 0..<(table?.bill?.orderList?.count ?? 0) {
            table?.bill?.orderList?[index].trangthai = 3
        }
        
        if let bill = table?.bill {
            HoaDon.updateBill(forBill: bill) { [weak self] error in
                if error != nil {
                    print(error ?? "")
                } else {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    @IBAction func btnBackWasTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

}

extension TableBillDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table?.bill?.orderList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderManagerViewCell", for: indexPath) as? OrderManagerViewCell else {
            fatalError("MakeOrderViewController: Can't dequeue for DishTableViewCell")
        }
        cell.order = table?.bill?.orderList?[indexPath.item]
        
        return cell
    }
    
    
}

extension TableBillDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if App.shared.staffInfo?.quyen != 1 && App.shared.staffInfo?.quyen != 2 && App.shared.staffInfo?.quyen != 3 {
            return nil
        }
        if table?.bill?.orderList?[indexPath.item].trangthai != 0 {
            return nil
        }
        let xoa = UITableViewRowAction(style: .default, title: "Xóa") { (_, index) in
            if let order = self.table?.bill?.orderList?[index.item] {
                let db = Firestore.firestore()
                db.collection("Order").document(order.idorder).delete { [weak self](error) in
                    if error == nil {
                        self?.fetchBillData()
                    }
                }
            }
            
        }
        let sua = UITableViewRowAction(style: .normal, title: "Sửa") { (_, index) in
            let order = self.table?.bill?.orderList?[index.item]
            
            let alert = UIAlertController(title: order?.dish?.tenmonan, message: "Số lượng: ", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: { (action) in
                guard let text = alert.textFields?.first?.text else { return }
                if let soluong = Int(text), soluong > 0 {
                    self.table?.bill?.orderList?[index.item].soluong = soluong
                    if let o = self.table?.bill?.orderList?[index.item] {
                        o.updateOrder(forOrder: o) { [weak self](error) in
                            self?.fetchBillData()
                        }
                    }
                } else {
                    let subAlert = UIAlertController(title: "Lỗi", message: "Hãy kiểm tra lại số lượng", preferredStyle: .alert)
                    subAlert.addAction(UIAlertAction(title: "Oke", style: .destructive, handler: nil))
                    self.present(subAlert, animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        return [xoa, sua]
    }
}

