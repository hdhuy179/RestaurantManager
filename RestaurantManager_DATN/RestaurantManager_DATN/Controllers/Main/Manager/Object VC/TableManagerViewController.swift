//
//  TableManagerViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 6/7/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class TableManagerViewController: UIViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtTableNumber: UITextField!
    @IBOutlet weak var txtTableSize: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    
    var table: BanAn?
    weak var delegate: ManagerDataViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addEndEditingTapGuesture()
        setupView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.fetchData()
    }
    
    func setupView() {
        
        if table != nil {
            lbTitle.text = "Thay đổi bàn ăn"
            if table?.daxoa == 1 {
                btnDelete.setTitle("Khôi phục", for: .normal)
            }
        } else {
//            btnDelete.backgroundColor = .gray
            btnDelete.setTitle("Hủy", for: .normal)
        }
        txtTableNumber.text = table?.sobanan
        if table?.soluongghe != nil {
            txtTableSize.text = String(table!.soluongghe!)
        }
        
        
    }
    
    @IBAction func btnConfirmWasTapped(_ sender: Any) {
        
        let number = txtTableNumber.text ?? ""
        let size = ((txtTableSize.text ?? "") as NSString).intValue
        
        let db = Firestore.firestore()
        
        if table == nil {
            table = BanAn()
        }
        
        db.collection("BanAn").document(table!.idbanan!).setData([
            "idbanan": table!.idbanan!,
            "sobanan": number,
            "soluongghe": size,
            "daxoa": 0
        ]) { err in
        }
        
        self.dismiss(animated: true)
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {
        if btnDelete.titleLabel?.text == "Hủy" {
            self.dismiss(animated: true)
            return
        }
        let db = Firestore.firestore()
        let will = table?.daxoa == 0 ? 1 : 0
        let message = will == 0 ? "Bạn có chắc chắn muốn khôi phục dữ liệu không" : "Bạn có chắc chắn muốn xóa dữ liệu không"
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        let xacnhan = UIAlertAction(title: "Xác nhận", style: .default) { (_) in
            db.collection("BanAn").document(self.table!.idbanan!).updateData(["daxoa": will])
            self.dismiss(animated: true)
        }
        let huy = UIAlertAction(title: "Hủy", style: .cancel)
        alert.addAction(xacnhan)
        alert.addAction(huy)
        self.present(alert, animated: true)
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
