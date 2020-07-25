//
//  StaffManagerViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 6/19/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit
import FirebaseAuth

class StaffManagerViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtStaffName: UITextField!
    @IBOutlet weak var swStaffAuthority: UISegmentedControl!
    @IBOutlet weak var swStaffAuthority2: UISegmentedControl!
    @IBOutlet weak var txtStaffPhone: UITextField!
    @IBOutlet weak var txtStaffAddress: UITextField!
    @IBOutlet weak var btnDelete: RaisedButton!
    @IBOutlet weak var btnResetPassword: RaisedButton!
    
    var staff: NhanVien?
    var forStaffDetail = false
    
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
        addEndEditingTapGuesture()
        if let staff = staff {
            lbTitle.text = "Thay thay đổi nhân viên"
            if staff.daxoa == 1 {
                btnDelete.setTitle("Khôi phục", for: .normal)
            }
            
            txtStaffName.text = staff.tennhanvien
            switch staff.quyen {
            case 0:
                break
            case 1:
                swStaffAuthority2.selectedSegmentIndex = 1
            case 2:
                swStaffAuthority.selectedSegmentIndex = 1
            case 3:
                swStaffAuthority.selectedSegmentIndex = 0
            case 4:
                swStaffAuthority.selectedSegmentIndex = 2
            case 5:
                swStaffAuthority2.selectedSegmentIndex = 0
            default: break
            }
            txtStaffPhone.text = staff.sodienthoai
            txtStaffAddress.text = staff.diachi
        }
        if forStaffDetail {
            lbTitle.text = "Thông tin cá nhân"
            txtStaffName.isEnabled = false
            txtStaffName.isDividerHidden = true
            swStaffAuthority.isEnabled = false
            swStaffAuthority2.isEnabled = false
            btnResetPassword.setTitle("Đổi mật khẩu", for: .normal)
            btnDelete.setTitle("Huỷ", for: .normal)
        }
    }
    
    @IBAction func swChangedValue(_ sender: UISegmentedControl) {
        if sender == swStaffAuthority {
            swStaffAuthority2.selectedSegmentIndex = -1
        } else {
            swStaffAuthority.selectedSegmentIndex = -1
        }
    }
    
    @IBAction func btnResetPasswordTapped(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: staff?.email ?? "") { [weak self](error) in
            if error == nil {
                self?.showAlert(title: "Đổi mật khẩu", message: "Vui lòng truy cập đến hòm thư \"\(self?.staff?.email ?? "")\" để đổi mật khẩu.")
            }
        }
    }
    
    @IBAction func btnConfirmWasTapped(_ sender: Any) {
        
        let db = Firestore.firestore()
        
        let staffName = txtStaffName.text ?? ""
        let staffPhone = txtStaffPhone.text ?? ""
        let staffAddress = txtStaffAddress.text ?? ""
        var author: Int? = nil
        
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
        
        if let staff = staff {
            db.collection("NhanVien").document(staff.idnhanvien).updateData(["tennhanvien":staffName, "sodienthoai": staffPhone, "diachi": staffAddress, "quyen": author!]) { [weak self] error in
                if error == nil {
                    if let supervc = self?.presentingViewController as? ManagerDataViewController {
                        supervc.fetchData()
                    }
                    if self?.forStaffDetail ?? false {
                        App.shared.staffInfo?.diachi = staffAddress
                        App.shared.staffInfo?.sodienthoai = staffPhone
                    }
                    self?.dismiss(animated: true)
                }
            }
            return
        }

        
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {
        if btnDelete.titleLabel?.text == "Huỷ" {
            self.dismiss(animated: true)
            return
        }
        let db = Firestore.firestore()
        let will = staff?.daxoa == 0 ? 1 : 0
        let message = will == 0 ? "Bạn có chắc chắn muốn khôi phục dữ liệu không" : "Bạn có chắc chắn muốn xóa dữ liệu không"
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        let xacnhan = UIAlertAction(title: "Xác nhận", style: .default) { (_) in
            db.collection("NhanVien").document(self.staff!.idnhanvien).updateData(["daxoa": will])
            self.dismiss(animated: true)
        }
        let huy = UIAlertAction(title: "Hủy", style: .cancel)
        alert.addAction(xacnhan)
        alert.addAction(huy)
        self.present(alert, animated: true)
    }
    
    @IBAction func btnBackWasTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
