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
    @IBOutlet weak var txtStartDate: DatePickerTextField!
    @IBOutlet weak var txtEndDate: DatePickerTextField!
    @IBOutlet weak var vSearch: UIView!
    @IBOutlet weak var btnSearch: RaisedButton!
    @IBOutlet weak var lbTitleReport: UILabel!
    @IBOutlet weak var ssvReportContent: SpreadsheetView!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var btnSaveReport: RaisedButton!
    
    weak var delegate: ManagerDataViewController?
    
    var reportType: ReportType!
    
    var report: BaoCao? {
        didSet {
            btnSaveReport.isEnabled = true
            reportDatas.removeAll()
            let splited = report?.noidung.split { $0 == "\n"}
            for item in splited ?? [] {
                let item = String(item)
                reportDatas.append(item.split { $0 == "\t"}.map(String.init))
            }
            lbTitleReport.text = title
        }
    }
    var reportDatas: [[String]] = [] {
        didSet {
            ssvReportContent.reloadData()
        }
    }
    
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
        btnSaveReport.setTitleColor(.lightGray, for: .disabled)
        btnSaveReport.isEnabled = false
        lbTitleReport.text = ""
        
        addEndEditingTapGuesture()
        txtStartDate.isDatePickerTextField(dateFormat: "dd/MM/yyyy")
        txtEndDate.isDatePickerTextField(maximumDate: Date(), dateFormat: "dd/MM/yyyy")
        txtStartDate.isClearIconButtonEnabled = true
        txtEndDate.isClearIconButtonEnabled = true
        
        btnSearch.pulseColor = .white
        
        ssvReportContent.dataSource = self
        ssvReportContent.delegate = self
        
        ssvReportContent.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        ssvReportContent.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
    }
    
    @IBAction func startDateTextFieldEditingDidEnd(_ sender: Any) {
        txtEndDate.isDatePickerTextField(minimumDate: Date.getDate(fromString: txtStartDate.text!, withDateFormat: "dd/MM/yyyy"), maximumDate: Date(), dateFormat: "dd/MM/yyyy")
    }
    
    @IBAction func endDateTextFieldEditingDidEnd(_ sender: Any) {
        txtStartDate.isDatePickerTextField(maximumDate: Date.getDate(fromString: txtEndDate.text!, withDateFormat: "dd/MM/yyyy"), dateFormat: "dd/MM/yyyy")
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
        
        guard let start = Date.getDate(fromString: txtStartDate.text ?? "", withDateFormat: "dd/MM/yyyy"),
        let end = Date.getDate(fromString: txtEndDate.text ?? "", withDateFormat: "dd/MM/yyyy") else { return }
        fetchData(from: start, toDate: end)
    }
    
    func fetchData(from: Date, toDate: Date) {
        switch reportType {
        case .income:
            Order.fetchData(from: from, toDate: toDate) { [weak self] (datas, err) in
                let datas = datas?.sorted(by: { $0.ngaytao?.timeIntervalSince1970 ?? 0 > $1.ngaytao?.timeIntervalSince1970 ?? 0})
                
                var reportContent = ""
                
                var totalBill = 0
                var totalMoney: Double = 0
                var totalOrder = 0
                
                var currentDate = ""
                
                var billDict: [String: Bool] = [:]
                var moneyCounter: Double = 0
                var orderCounter: Int = 0
                
                currentDate = datas?.last?.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") ?? ""
                for item in datas?.reversed() ?? [] {
                    if currentDate == item.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") {
                        orderCounter += item.soluong
                        moneyCounter += Double(item.soluong)*(item.dish?.dongia ?? 0)
                        if billDict[item.idhoadon ?? ""] == nil {
                            billDict[item.idhoadon ?? ""] = true
                        }
                    } else {
                        reportContent += " \(currentDate)\t \(orderCounter)\t \(billDict.count)\t \(moneyCounter.splittedByThousandUnits())\n"
                        totalBill += billDict.count
                        totalMoney += moneyCounter
                        totalOrder += orderCounter
                        currentDate = item.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") ?? ""
                        billDict.removeAll()
                        billDict[item.idhoadon ?? ""] = true
                        orderCounter = item.soluong
                        moneyCounter = Double(item.soluong)*(item.dish?.dongia ?? 0)
                    }
                }
                reportContent += " \(currentDate)\t \(orderCounter)\t \(billDict.count)\t \(moneyCounter.splittedByThousandUnits())\n"
                totalBill += billDict.count
                totalMoney += moneyCounter
                totalOrder += orderCounter
                reportContent += " Tổng cộng:\t \(totalOrder)\t \(totalBill)\t \(totalMoney.splittedByThousandUnits())\n"

                let title = "\(from.convertToString(withDateFormat: "dd/MM/yy"))-\(toDate.convertToString(withDateFormat: "dd/MM/yy")): TK_Doanh số"
                let staffData = App.shared.staffInfo
                self?.report = BaoCao(idnhanvien: staffData?.idnhanvien ?? "", tieude: title, noidung: reportContent, ngaytao: Date(), loaibaocao: 1, daxoa: 0, staff: staffData)
            }
        case .bestSeller:
            Order.fetchData(from: from, toDate: toDate) { [weak self] (datas, err) in
                var dishDict: [MonAn: Int] = [:]
                
                for item in datas ?? [] {
                    if let dish = item.dish {
                        dishDict[dish] = dishDict[dish] == nil ? item.soluong : dishDict[dish]! + item.soluong
                    }
                }
                let bestSellerList = dishDict.sorted (by: { $0.value > $1.value })
                
                var reportContent = ""
                for (index, (key, value)) in bestSellerList.enumerated() {
                    reportContent += "\(index+1).\t\(key.tenmonan)\t\(value) \(key.donvimonan.replacingOccurrences(of: "1", with: "").trimmed)\n"
                }
                reportContent.removeLast()

                let title = "\(from.convertToString(withDateFormat: "dd/MM/yy"))-\(toDate.convertToString(withDateFormat: "dd/MM/yy")): TK_Món bán chạy nhất"
                
                let staffData = App.shared.staffInfo
                self?.report = BaoCao(idnhanvien: staffData?.idnhanvien ?? "", tieude: title, noidung: reportContent, ngaytao: Date(), loaibaocao: 2, daxoa: 0, staff: staffData)
            }
        case .stuffUsed:
            var orderList: [Order] = []
            var exportList: [PhieuXuat] = []
            var counter = 0
            var maxCounter = 2
            Order.fetchData(from: from, toDate: toDate) { (datas, err) in
                let datas = datas?.sorted(by: { $0.ngaytao?.timeIntervalSince1970 ?? 0 > $1.ngaytao?.timeIntervalSince1970 ?? 0})
                counter += 1
                orderList = datas ?? []
                if counter == maxCounter {
                    setupData()
                }
            }
            PhieuXuat.fetchData(from: from, toDate: toDate) { (datas, err) in
                let datas = datas?.sorted(by: { $0.ngaytao?.timeIntervalSince1970 ?? 0 > $1.ngaytao?.timeIntervalSince1970 ?? 0})
                counter += 1
                exportList = datas ?? []
                if counter == maxCounter {
                    setupData()
                }
            }
            
            func setupData() {
                var dateDict: [String: Bool] = [:]
                var orderDict: [String: [Order]] = [:]
                var exportDict: [String: [PhieuXuat]] = [:]
                
                for item in orderList {
                    if let dateStr = item.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") {
                        dateDict[dateStr] = true
                        if orderDict[dateStr] == nil {
                            orderDict[dateStr] = [item]
                        } else {
                            orderDict[dateStr]?.append(item)
                        }
                    }
                }
                
                for item in exportList {
                    if let dateStr = item.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") {
                        dateDict[dateStr] = true
                        if exportDict[dateStr] == nil {
                            exportDict[dateStr] = [item]
                        } else {
                            exportDict[dateStr]?.append(item)
                        }
                    }
                }
                
                for (key, _) in dateDict {
                    
                }
            }
        default:
            break
        }
    }
    
    @IBAction func btnSaveWasTapped(_ sender: Any) {
        btnSaveReport.isEnabled = false
        if let report = report {
            BaoCao.saveReport(data: report) { (err) in
                if err == nil {
                    self.showAlert(title: "Thông báo", message: "Đã lưu báo cáo")
                }
            }
        }
    }
    
    @IBAction func btnBackWasTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension CreateReportManagerViewController: SpreadsheetViewDataSource {
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow column: Int) -> CGFloat {
        return 50
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch reportType {
        case .income:
            if column == 1 {
                return 70
            } else if column == 2 {
                return 90
            }
            return 120
        case .bestSeller:
            if column == 0 {
                return 50
            } else if column == 2 {
                return 90
            }
            return UIScreen.main.bounds.width - 50 - 45 - 90 - 5
        case .stuffUsed:
            break
        default:
            break
        }
        return 0
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        switch reportType {
        case .income:
            return 4
        case .bestSeller:
            return 3
        case .stuffUsed:
            break
        default:
            break
        }
        return 0
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch reportType {
        case .income:
            return reportDatas.count + 1
        case .bestSeller:
            return reportDatas.count + 1
        case .stuffUsed:
            break
        default:
            break
        }
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        switch reportType {
        case .income:
            if indexPath.row == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                if indexPath.column == 0 {
                    cell.label.text = "Ngày"
                } else if indexPath.column == 1 {
                    cell.label.text = "Số order"
                } else if indexPath.column == 2 {
                    cell.label.text = "Số hoá đơn"
                } else {
                    cell.label.text = "Tổng thu"
                }
                cell.label.textAlignment = .center
                cell.setNeedsLayout()

                return cell
            } else if indexPath.row == reportDatas.count {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                cell.label.text = reportDatas[indexPath.row - 1][indexPath.column]
                cell.label.textAlignment = .center
                cell.setNeedsLayout()

                return cell
            } else {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.label.textAlignment = .center
                cell.label.text = reportDatas[indexPath.row - 1][indexPath.column]
                
                return cell
            }
        case .bestSeller:
            if indexPath.row == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                if indexPath.column == 0 {
                    cell.label.text = "STT"
                } else if indexPath.column == 1 {
                    cell.label.text = "Tên món"
                } else {
                    cell.label.text = "Số lượng"
                }
                cell.label.textAlignment = .center
                cell.setNeedsLayout()

                return cell
            } else {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                
                cell.label.text = reportDatas[indexPath.row - 1][indexPath.column]
                cell.label.textAlignment = .center
                return cell
            }
        case .stuffUsed:
            break
        default:
            break
        }
        return nil
    }
}

extension CreateReportManagerViewController: SpreadsheetViewDelegate {
    
}
