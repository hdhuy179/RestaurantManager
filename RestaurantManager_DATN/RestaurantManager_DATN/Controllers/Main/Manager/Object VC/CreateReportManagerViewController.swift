//
//  ReportManagerViewController.swift
//  RestaurantManager_DATN
//
//  Created by HuyHoangDinh on 7/17/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

enum ReportType {
    case income, bestSeller, stuffUsed
}

class CreateReportManagerViewController: UIViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtStartDate: TextField!
    @IBOutlet weak var txtEndDate: TextField!
    @IBOutlet weak var vSearch: UIView!
    @IBOutlet weak var btnSearch: RaisedButton!
    @IBOutlet weak var lbTitleReport: UILabel!
    @IBOutlet weak var ssvReportContent: SpreadsheetView!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var btnSaveReport: RaisedButton!
    
    weak var delegate: ManagerDataViewController?
    
    var reportType: ReportType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        delegate?.fetchData()
    }
    
    private func setupView() {
        btnSaveReport.isEnabled = false
        switch reportType {
        case .income:
            lbTitle.text = "Tạo báo cáo doanh số"
        case .bestSeller:
            lbTitle.text = "Tạo thống kê món bán chạy"
        case .stuffUsed:
            lbTitle.text = "Tạo thống kê vật phẩm sử dụng"
        default:
            break
        }
        
        lbTitleReport.text = ""
//        tvReportContent.text = "1. Cơm cá kho tộ - 63 niêu \n2. Cơm gà chua ngọt - 53 đĩa \n3. Cơm trắng - 40 tô \n4. Cơm thịt rang cháy cạnh - 39 đĩa\n5. Gà Rang muối ớt - 33 con\n6. Cá thu rán - 29 khúc\n7. Cá thu sốt chua ngọt - 28 đĩa\n8. Rau muốn xào tỏi - 28 đĩa\n9. Gà không lối thoát - 26 con\n10. Thịt lợn mường - 25 đĩa\n11. Thịt nguội - 22 đĩa\n12. Rau cần xào thịt bò - 10 đĩa"
        
        addEndEditingTapGuesture()
        txtStartDate.isDatePickerTextField(dateFormat: "dd/MM/yyyy")
        txtEndDate.isDatePickerTextField(maximumDate: Date(), dateFormat: "dd/MM/yyyy")
        txtStartDate.isClearIconButtonEnabled = true
        txtEndDate.isClearIconButtonEnabled = true
        
        btnSearch.pulseColor = .white
        
    }
    
    @IBAction func startDateTextFieldEditingDidEnd(_ sender: Any) {
        txtEndDate.isDatePickerTextField(minimumDate: Date.getDate(fromString: txtStartDate.text!, withDateFormat: "dd/MM/yyyy"), maximumDate: Date(), dateFormat: "dd/MM/yyyy")
    }
    
    @IBAction func endDateTextFieldEditingDidEnd(_ sender: Any) {
        txtStartDate.isDatePickerTextField(maximumDate: Date.getDate(fromString: txtEndDate.text!, withDateFormat: "dd/MM/yyyy"))
        //        checkSearchBillEnable()
    }
    
    func checkSearchBillEnable() {
        if Date.getDate(fromString: txtStartDate.text!, withDateFormat: "dd/MM/yyyy") != nil &&
            Date.getDate(fromString: txtEndDate.text!, withDateFormat: "dd/MM/yyyy") != nil &&
            Date.getDate(fromString: txtStartDate.text!, withDateFormat: "dd/MM/yyyy")!.timeIntervalSince1970 <= Date.getDate(fromString: txtEndDate.text!, withDateFormat: "dd/MM/yyyy")!.timeIntervalSince1970 {
            btnSearch.isEnabled = true
            btnSearch.backgroundColor = .systemGreen
        } else {
            btnSearch.isEnabled = false
            btnSearch.backgroundColor = .systemGray
        }
    }
    
    @IBAction func btnSearchTapped(_ sender: Any) {
        
        if txtStartDate.text?.isEmpty == true {
            txtStartDate.text = txtEndDate.text
        } else if txtEndDate.text?.isEmpty == true {
            txtEndDate.text = txtStartDate.text
        }
        
        
    }
    
    @IBAction func btnBackWasTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
