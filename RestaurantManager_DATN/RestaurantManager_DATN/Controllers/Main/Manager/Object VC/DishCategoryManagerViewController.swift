//
//  DishCategoryManagerViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 6/1/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class DishCategoryManagerViewController: UIViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtDishCategoryName: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    
    var dishCategory: TheLoaiMonAn?
    weak var delegate: ManagerDataViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.fetchData()
    }
    
    func setupView() {
//        btnDelete.isEnabled = false

        if dishCategory != nil {
            lbTitle.text = "Thay đổi bàn ăn"
            
            if dishCategory?.daxoa == 1 {
                btnDelete.setTitle("Khôi phục", for: .normal)
            }
        } else {
//            btnDelete.backgroundColor = .gray
            btnDelete.setTitle("Hủy", for: .normal)
        }
        txtDishCategoryName.text = dishCategory?.tentheloaimonan ?? ""
        addEndEditingTapGuesture()
    }
    
    @IBAction func btnConfirmWasTapped(_ sender: Any) {
        let dishName = txtDishCategoryName.text ?? ""
        
        let db = Firestore.firestore()
        
        if dishCategory == nil {
            dishCategory = TheLoaiMonAn()
        }
        
        db.collection("TheLoaiMonAn").document(self.dishCategory!.idtheloaimonan!).setData([
            "idtheloaimonan": self.dishCategory!.idtheloaimonan!,
            "tentheloaimonan": dishName,
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
        let will = dishCategory?.daxoa == 0 ? 1 : 0
        let message = will == 0 ? "Bạn có chắc chắn muốn khôi phục dữ liệu không" : "Bạn có chắc chắn muốn xóa dữ liệu không"
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        let xacnhan = UIAlertAction(title: "Xác nhận", style: .default) { (_) in
            db.collection("TheLoaiMonAn").document(self.dishCategory!.idtheloaimonan!).updateData(["daxoa": will])
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
