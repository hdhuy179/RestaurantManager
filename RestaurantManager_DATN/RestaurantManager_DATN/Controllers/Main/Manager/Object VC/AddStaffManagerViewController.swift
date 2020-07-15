//
//  StaffManagerViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 6/19/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit
import FirebaseAuth

class AddStaffManagerViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtStaffName: UITextField!
    @IBOutlet weak var swStaffAuthority: UISegmentedControl!
    @IBOutlet weak var swStaffAuthority2: UISegmentedControl!
    @IBOutlet weak var txtStaffPhone: UITextField!
    @IBOutlet weak var txtStaffAddress: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    
    weak var delegate: ManagerDataViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addEndEditingTapGuesture()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.fetchData()
    }
    
    @IBAction func swChangedValue(_ sender: UISegmentedControl) {
        if sender == swStaffAuthority {
            swStaffAuthority2.selectedSegmentIndex = -1
        } else {
            swStaffAuthority.selectedSegmentIndex = -1
        }
    }
    
    @IBAction func btnConfirmWasTapped(_ sender: Any) {
        
        let db = Firestore.firestore()
        
        let staffName = txtStaffName.text ?? ""
        let staffPhone = txtStaffPhone.text ?? ""
        let staffAddress = txtStaffAddress.text ?? ""
        var author: Int? = nil
        
        if txtEmail.text?.isEmpty == true {
            self.showAlert(title: "Vui lòng nhập Email đăng nhập", message: "") { [weak self] in
                self?.txtEmail.becomeFirstResponder()
            }
            return
        }
        
        if txtPassword.text?.isEmpty == true {
            self.showAlert(title: "Vui lòng nhập mật khẩu đăng nhập", message: "") { [weak self] in
                self?.txtPassword.becomeFirstResponder()
            }
            
            return
        }
        
        switch swStaffAuthority.selectedSegmentIndex {
        case 0:
            author = 3
        case 1:
            author = 2
        case 2:
            author = 4
        default: break
        }
        
        switch swStaffAuthority2.selectedSegmentIndex {
        case 0:
            author = 5
        case 1:
            author = 1
        default: break
        }
        
        if author == nil {
            self.showAlert(title: "Vui lòng chọn quyền của nhân viên", message: "")
            return
        }
        
        Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { [weak self] (data, error) in
            if let uid = data?.user.uid {
                db.collection("NhanVien").document(uid).setData(["daxoa": 0, "diachi": staffAddress, "email": self!.txtEmail.text!, "idnhanvien": uid, "idtaikhoandangnhap": uid, "quyen": author!, "sodienthoai": staffPhone, "tennhanvien": staffName]) {[weak self] error in
                    
                    if error == nil {
                        self?.dismiss(animated: true)
                    }
                }
            }
        }
        
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnBackWasTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
