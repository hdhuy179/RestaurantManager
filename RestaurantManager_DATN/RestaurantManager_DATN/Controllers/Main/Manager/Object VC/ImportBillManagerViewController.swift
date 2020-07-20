//
//  ImportBillManagerViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 7/12/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class ImportBillManagerViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtBillNo: TextField!
    @IBOutlet weak var txtStuffName: TextField!
    @IBOutlet weak var txtStuffUnit: TextField!
    @IBOutlet weak var txtStuffAmount: TextField!
    @IBOutlet weak var txtBillCreatedDate: TextField!
    @IBOutlet weak var txtBillCreator: TextField!
    @IBOutlet weak var swOutOfDate: UISwitch!
    @IBOutlet weak var btnDelete: RaisedButton!
    @IBOutlet weak var btnConfirm: RaisedButton!
    
    var importBill: PhieuNhap?
    
    var forDetail: Bool = false
    
    var staff: NhanVien? {
        didSet {
            txtBillCreator.text = staff?.tennhanvien
        }
    }
    weak var delegate: ManagerDataViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addEndEditingTapGuesture()
        staff = importBill?.creatorStaff
        setupView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.fetchData()
    }
    
    func setupView() {
        txtBillCreatedDate.isDatePickerTextField(maximumDate: Date(),dateFormat: "dd-MM-yyyy hh:MM:ss")
        if importBill != nil {
            lbTitle.text = "Thay đổi phiếu nhập"
            txtBillNo.text = importBill?.maphieu
            txtStuffName.text = importBill?.tenvatpham
            txtStuffUnit.text = importBill?.donvi
            txtStuffAmount.text = String(importBill?.soluong ?? 0)
            
            txtBillCreatedDate.text = importBill?.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy hh:MM:ss")
            if importBill?.daxoa == 1 {
                btnDelete.setTitle("Khôi phục", for: .normal)
            }
        } else {
            //            btnDelete.backgroundColor = .gray
            btnDelete.setTitle("Hủy", for: .normal)
        }
        
        if forDetail {
            lbTitle.text = "Chi tiết phiếu nhập"
            txtBillNo.isEnabled = false
            txtStuffName.isEnabled = false
            txtStuffUnit.isEnabled = false
            txtStuffAmount.isEnabled = false
            txtBillCreator.isEnabled = false
            swOutOfDate.isEnabled = false
            btnDelete.isHidden = true
            btnConfirm.isHidden = true
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(txtCategoryTapped))
        txtBillCreator.addGestureRecognizer(tapGesture)
    }
    
    @objc private func txtCategoryTapped() {
        let presentHandler = PresentHandler()
        presentHandler.presentManagerDataVC(self, manageType: .staff, isForPickData: true)
    }
    
    @IBAction func btnConfirmWasTapped(_ sender: Any) {
        
        let billNo = txtBillNo.text ?? ""
        let stuffName = txtStuffName.text ?? ""
        let stuffUnit = txtStuffUnit.text ?? ""
        let stuffAmount = ((txtStuffAmount.text ?? "") as NSString).floatValue
        let createdDate =  Date.getDate(fromString: txtBillCreatedDate.text ?? "", withDateFormat: "dd-MM-yyyy hh:MM:ss")
        let outOfDate = swOutOfDate.isOn ? 1 : 0
        
//        let billNo = txtBillCreatedDate.text

        let db = Firestore.firestore()

        if importBill == nil {
            importBill = PhieuNhap()
        }

        db.collection("PhieuNhap").document(importBill!.idphieunhap).setData([
            "idphieunhap": importBill?.idphieunhap ?? "",
            "idnhanvien": staff?.idnhanvien ?? "",
            "maphieu": billNo,
            "ngaytao": createdDate,
            "quahan": outOfDate,
            "soluong": stuffAmount,
            "donvi": stuffUnit,
            "tenvatpham": stuffName,
            "daxoa": importBill?.daxoa ?? 0
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
        let will = importBill?.daxoa == 0 ? 1 : 0
        let message = will == 0 ? "Bạn có chắc chắn muốn khôi phục dữ liệu không" : "Bạn có chắc chắn muốn xóa dữ liệu không"
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        let xacnhan = UIAlertAction(title: "Xác nhận", style: .default) { (_) in
            db.collection("PhieuNhap").document(self.importBill!.idphieunhap).updateData(["daxoa": will])
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
extension ImportBillManagerViewController: ManagerPickedData {
    func dataWasPicked(data: Any) {
        if let data = data as? NhanVien {
            staff = data
        }
    }
    
}
