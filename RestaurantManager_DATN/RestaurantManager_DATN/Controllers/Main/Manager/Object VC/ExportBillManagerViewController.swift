//
//  ExportBillManagerViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 7/12/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class ExportBillManagerViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtImportBill: TextField!
    @IBOutlet weak var txtStuffName: TextField!
    @IBOutlet weak var txtStuffAmount: TextField!
    @IBOutlet weak var txtBillCreatedDate: DatePickerTextField!
    @IBOutlet weak var txtStaffCreator: TextField!
    @IBOutlet weak var txtStaffExportor: TextField!
    @IBOutlet weak var swIsExported: UISwitch!
    @IBOutlet weak var btnDelete: RaisedButton!
    @IBOutlet weak var btnConfirm: RaisedButton!
    
    var forShowDetails: Bool = false
    
    private var isForExporter = false
    
    var exportBill: PhieuXuat?
    var importBill: PhieuNhap?
    
    var staffExport: NhanVien? {
        didSet {
            txtStaffExportor.text = staffExport?.tennhanvien
        }
    }
    var staffCreate: NhanVien? {
        didSet {
            txtStaffCreator.text = staffCreate?.tennhanvien
        }
    }
    
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
        
        txtBillCreatedDate.isDatePickerTextField(maximumDate: Date(), dateFormat: "dd-MM-yyyy hh:MM:ss")
        
        if exportBill != nil {
            staffCreate = exportBill?.creatorStaff
            staffExport = exportBill?.exportStaff
            
            txtBillCreatedDate.isDatePickerTextField(minimumDate: importBill?.ngaytao,maximumDate: Date(), dateFormat: "dd-MM-yyyy hh:MM:ss")
            
            lbTitle.text = "Thay đổi phiếu xuất"
            txtImportBill.text = importBill?.maphieu
            txtStuffName.text = importBill?.tenvatpham
            txtStuffAmount.text = String(exportBill?.soluong ?? 0)
            txtBillCreatedDate.text = exportBill?.ngaytao?.convertToString()
            
            swIsExported.isOn = exportBill?.trangthai == 1
            if exportBill?.daxoa == 1 {
                btnDelete.setTitle("Khôi phục", for: .normal)
            }
        } else {
            //            btnDelete.backgroundColor = .gray
            btnDelete.setTitle("Hủy", for: .normal)
        }
        
        if forShowDetails {
            txtBillCreatedDate.isEnabled = false
            txtImportBill.isEnabled = false
            txtStuffName.isEnabled = false
            txtStuffAmount.isEnabled = false
            txtBillCreatedDate.isEnabled = false
            txtStaffCreator.isEnabled = false
            txtStaffExportor.isEnabled = false
            swIsExported.isEnabled = false
            
            btnDelete.isHidden = true
            btnConfirm.isHidden = true
            
            txtBillCreatedDate.isDividerHidden = true
            txtImportBill.isDividerHidden = true
            txtStuffName.isDividerHidden = true
            txtStuffAmount.isDividerHidden = true
            txtBillCreatedDate.isDividerHidden = true
            txtStaffCreator.isDividerHidden = true
            txtStaffExportor.isDividerHidden = true
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(txtCreatorTapped))
        txtStaffCreator.addGestureRecognizer(tapGesture)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(txtExporterTapped))
        txtStaffExportor.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(txtImportBillTapped))
        txtImportBill.addGestureRecognizer(tapGesture3)
        
    }
    
    @objc private func txtImportBillTapped() {
        let presentHandler = PresentHandler()
        presentHandler.presentManagerDataVC(self, manageType: .importBill, isForPickData: true)
    }
    
    @objc private func txtCreatorTapped() {
        isForExporter = false
        let presentHandler = PresentHandler()
        presentHandler.presentManagerDataVC(self, manageType: .staff, isForPickData: true)
    }
    
    @objc private func txtExporterTapped() {
        isForExporter = true
        let presentHandler = PresentHandler()
        presentHandler.presentManagerDataVC(self, manageType: .staff, isForPickData: true)
    }
    
    @IBAction func btnConfirmWasTapped(_ sender: Any) {

        let idCreator = staffCreate?.idnhanvien ?? ""
        let idExportor = staffExport?.idnhanvien ?? ""
        let idImportBill = importBill?.idphieunhap ?? ""
        let createdDate =  Date.getDate(fromString: txtBillCreatedDate.text ?? "", withDateFormat: "dd-MM-yyyy hh:MM:ss")
        let amount = ((txtStuffAmount.text ?? "") as NSString).floatValue
        let state = swIsExported.isOn == true ? 1 : 0

        //        let billNo = txtBillCreatedDate.text

        let db = Firestore.firestore()

        if exportBill == nil {
            exportBill = PhieuXuat()
        }

        db.collection("PhieuXuat").document(exportBill!.idphieuxuat).setData([
            
            "idphieuxuat": exportBill!.idphieuxuat!,
            "idnhanvientaophieu": idCreator,
            "idnhanvienxuatphieu": idExportor,
            "idphieunhap": idImportBill,
            "ngaytao": createdDate,
            "soluong": amount,
            "trangthai": state,
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
        let will = exportBill?.daxoa == 0 ? 1 : 0
        let message = will == 0 ? "Bạn có chắc chắn muốn khôi phục dữ liệu không" : "Bạn có chắc chắn muốn xóa dữ liệu không"
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        let xacnhan = UIAlertAction(title: "Xác nhận", style: .default) { (_) in
            db.collection("PhieuXuat").document(self.exportBill!.idphieuxuat).updateData(["daxoa": will])
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
extension ExportBillManagerViewController: ManagerPickedData {
    func dataWasPicked(data: Any) {
        if let data = data as? NhanVien {
            if isForExporter {
                staffExport = data
            } else {
                staffCreate = data
            }
        }
        if let data = data as? PhieuNhap {
            importBill = data
            txtImportBill.text = data.maphieu
            txtStuffName.text = data.tenvatpham
            
            txtBillCreatedDate.text = ""
            txtStuffAmount.text = ""
            txtBillCreatedDate.isDatePickerTextField(minimumDate: importBill?.ngaytao,maximumDate: Date(), dateFormat: "dd-MM-yyyy hh:MM:ss")
        }
    }
    
}
