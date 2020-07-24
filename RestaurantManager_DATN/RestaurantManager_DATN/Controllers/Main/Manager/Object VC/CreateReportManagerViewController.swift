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
    
    var startHeaderRow: Int?
    lazy var yellowRow: [Int] = []
    
    var reportType: ReportType!
    
    var report: BaoCao? {
        didSet {
            btnSaveReport.isEnabled = true
            reportDatas.removeAll()
            let splited = report?.noidung.split { $0 == "\n"}
            for (index, item) in splited?.enumerated() ?? [].enumerated() {
                let item = String(item)
                reportDatas.append(item.split { $0 == "\t"}.map(String.init))
                
                if reportType == .income {
                    if reportDatas.last?[2] == " 0" {
                        yellowRow.append(index)
                    }
                }
            }
            lbTitleReport.text = report?.tieude
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
        startHeaderRow = nil
        yellowRow.removeAll()
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
                
                var billDict: [String: Bool] = [:]
                var moneyCounter: Double = 0
                var orderCounter: Int = 0
                
                let dateList = Date.getDateArray(fromDate: from, toDate: toDate, byComponent: .day, value: 1)
                
                for date in dateList {
                    let dateStr = date.convertToString(withDateFormat: "dd/MM/yyyy")
                    let orderList = datas?.filter({ ($0.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") == dateStr )})
                    
                    for item in orderList ?? [] {
                        orderCounter += item.soluong
                        moneyCounter += Double(item.soluong)*(item.dish?.dongia ?? 0)
                        if billDict[item.idhoadon ?? ""] == nil {
                            billDict[item.idhoadon ?? ""] = true
                        }
                    }
                    
                    reportContent += " \(dateStr)\t \(orderCounter)\t \(billDict.count)\t \(moneyCounter.splittedByThousandUnits())\n"
                    totalBill += billDict.count
                    totalMoney += moneyCounter
                    totalOrder += orderCounter
                    billDict.removeAll()
                    orderCounter = 0
                    moneyCounter = 0
                }
                
//                currentDate = datas?.last?.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") ?? ""
//                for item in datas?.reversed() ?? [] {
//                    if currentDate == item.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") {
//                        orderCounter += item.soluong
//                        moneyCounter += Double(item.soluong)*(item.dish?.dongia ?? 0)
//                        if billDict[item.idhoadon ?? ""] == nil {
//                            billDict[item.idhoadon ?? ""] = true
//                        }
//                    } else {
//                        reportContent += " \(currentDate)\t \(orderCounter)\t \(billDict.count)\t \(moneyCounter.splittedByThousandUnits())\n"
//                        totalBill += billDict.count
//                        totalMoney += moneyCounter
//                        totalOrder += orderCounter
//                        currentDate = item.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") ?? ""
//                        billDict.removeAll()
//                        billDict[item.idhoadon ?? ""] = true
//                        orderCounter = item.soluong
//                        moneyCounter = Double(item.soluong)*(item.dish?.dongia ?? 0)
//                    }
//                }
//                reportContent += " \(currentDate)\t \(orderCounter)\t \(billDict.count)\t \(moneyCounter.splittedByThousandUnits())\n"
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
            var importList: [PhieuNhap] = []
            var counter = 0
            var maxCounter = 3
            
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
            PhieuNhap.fetchAllDataAvailable { (datas, err) in
                counter += 1
                importList = datas ?? []
                if counter == maxCounter {
                    setupData()
                }
            }
            func setupData() {
                var reportContent = ""
                
                var orderDict: [String: [String]] = [:]
                var exportDict: [String: [String]] = [:]
                
                var dishDict: [MonAn: Int] = [:]
                var stuffDict: [PhieuNhap: Float] = [:]
                var currentSetDate: String = ""
                
                var allDishDict: [MonAn: Int] = [:]
                var allStuffDict: [PhieuNhap: Float] = [:]
                
                for item in orderList {
                    if let dish = item.dish {
                        allDishDict[dish] = allDishDict[dish] == nil ? item.soluong : allDishDict[dish]! + item.soluong
                    }
                    if let dateStr = item.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") {
                        if currentSetDate != dateStr && dishDict.isEmpty == false {
                            for (key, value) in dishDict {
                                if orderDict[currentSetDate] == nil {
                                    orderDict[currentSetDate] = ["\(key.tenmonan) - \(value) \(key.donvimonan.replacingOccurrences(of: "1", with: "").trimmed)"]
                                } else {
                                    orderDict[currentSetDate]?.append("\(key.tenmonan) - \(value) \(key.donvimonan.replacingOccurrences(of: "1", with: "").trimmed)")
                                }
                            }
                            dishDict.removeAll()
                            if let dish = item.dish {
                                dishDict[dish] = item.soluong
                            }
                            currentSetDate = dateStr
                        } else if currentSetDate == dateStr, let dish = item.dish {
                            dishDict[dish] = dishDict[dish] == nil ? item.soluong : dishDict[dish]! + item.soluong
                        } else {
                            currentSetDate = dateStr
                            if let dish = item.dish {
                                dishDict[dish] = item.soluong
                            }
                        }
                    }
                }
                for (key, value) in dishDict {
                    if orderDict[currentSetDate] == nil {
                        orderDict[currentSetDate] = ["\(key.tenmonan) - \(value) \(key.donvimonan.replacingOccurrences(of: "1", with: "").trimmed)"]
                    } else {
                        orderDict[currentSetDate]?.append("\(key.tenmonan) - \(value) \(key.donvimonan.replacingOccurrences(of: "1", with: "").trimmed)")
                    }
                }
                currentSetDate = ""
                for item in exportList {
                    if let imp = importList.first(where: { $0.idphieunhap == item.idphieunhap }) {
                        allStuffDict[imp] = allStuffDict[imp] == nil ? item.soluong : allStuffDict[imp]! + item.soluong
                    }
                    if let dateStr = item.ngaytao?.convertToString(withDateFormat: "dd/MM/yyyy") {
                        if currentSetDate != dateStr && stuffDict.isEmpty == false {
                            for (key, value) in stuffDict {
                                if exportDict[currentSetDate] == nil {
                                    exportDict[currentSetDate] = ["\(key.tenvatpham) - \(value.clean) \(key.donvi)"]
                                } else {
                                    exportDict[currentSetDate]?.append("\(key.tenvatpham) - \(value.clean) \(key.donvi)")
                                }
                            }
                            stuffDict.removeAll()
                            if let imp = importList.first(where: { $0.idphieunhap == item.idphieunhap }) {
                                stuffDict[imp] = item.soluong
                            }
                            currentSetDate = dateStr
                        } else if currentSetDate == dateStr, let imp = importList.first(where: { $0.idphieunhap == item.idphieunhap }) {
                            stuffDict[imp] = stuffDict[imp] == nil ? item.soluong : stuffDict[imp]! + item.soluong
                        } else {
                            currentSetDate = dateStr
                            if let imp = importList.first(where: { $0.idphieunhap == item.idphieunhap }) {
                                stuffDict[imp] = item.soluong
                            }
                        }
                    }
                }
                for (key, value) in stuffDict {
                    if exportDict[currentSetDate] == nil {
                        exportDict[currentSetDate] = ["\(key.tenvatpham) - \(value.clean) \(key.donvi)"]
                    } else {
                        exportDict[currentSetDate]?.append("\(key.tenvatpham) - \(value.clean) \(key.donvi)")
                    }
                }
                
                let dateList = Date.getDateArray(fromDate: from, toDate: toDate, byComponent: .day, value: 1)
                for date in dateList {
                    let dateStr = date.convertToString(withDateFormat: "dd/MM/yyyy")
                    if orderDict[dateStr]?.first == nil && exportDict[dateStr]?.first == nil {
                        continue
                    }
                    reportContent += "\(dateStr)\t\(orderDict[dateStr]?.first ?? " ")\t\(exportDict[dateStr]?.first ?? " ")\n"
                    if orderDict[dateStr]?.isEmpty == false {
                        orderDict[dateStr]?.removeFirst()
                    }
                    if exportDict[dateStr]?.isEmpty == false {
                        exportDict[dateStr]?.removeFirst()
                    }
                    for _ in 1..<(max(orderDict[dateStr]?.count ?? 2, exportDict[dateStr]?.count ?? 2)) {
                        if orderDict[dateStr]?.first == nil && exportDict[dateStr]?.first == nil {
                            break
                        }
                        reportContent += " \t\(orderDict[dateStr]?.first ?? " ")\t\(exportDict[dateStr]?.first ?? " ")\n"
                        if orderDict[dateStr]?.isEmpty == false {
                            orderDict[dateStr]?.removeFirst()
                        }
                        if exportDict[dateStr]?.isEmpty == false {
                            exportDict[dateStr]?.removeFirst()
                        }
                    }
                }
                
                let currentDishItem = allDishDict.first
                let currentStuffItem = allStuffDict.first
                reportContent += "Tổng\t\(currentDishItem?.key.tenmonan ?? " ") - \(currentDishItem?.value ?? 0) \(currentDishItem?.key.donvimonan.replacingOccurrences(of: "1", with: "").trimmed ?? " ")\t\(currentStuffItem?.key.tenvatpham ?? " ") - \(currentStuffItem?.value.clean ?? "0") \(currentStuffItem?.key.donvi ?? " ")\n"
                if allDishDict.isEmpty == false, let currentDishItem = currentDishItem {
                    allDishDict.removeValue(forKey: currentDishItem.key)
                }
                if allStuffDict.isEmpty == false, let currentStuffItem = currentStuffItem {
                    allStuffDict.removeValue(forKey: currentStuffItem.key)
                }
                for _ in 1..<(max(allDishDict.count, allStuffDict.count, 2)) {
                    if allDishDict.first == nil && allStuffDict.first == nil {
                        break
                    }
                    if let currentDishItem = allDishDict.first {
                        reportContent += " \t\(currentDishItem.key.tenmonan ) - \(currentDishItem.value ) \(currentDishItem.key.donvimonan.replacingOccurrences(of: "1", with: "").trimmed )"
                        allDishDict.removeValue(forKey: currentDishItem.key)
                    } else {
                        reportContent += " \t "
                    }
                    if let currentStuffItem = allStuffDict.first {
                        reportContent += "\t\(currentStuffItem.key.tenvatpham ) - \(currentStuffItem.value.clean ) \(currentStuffItem.key.donvi )\n"
                        allStuffDict.removeValue(forKey: currentStuffItem.key)
                    } else {
                        reportContent += "\t \n"
                    }
                }
                reportContent.removeLast()
                
                let title = "\(from.convertToString(withDateFormat: "dd/MM/yy"))-\(toDate.convertToString(withDateFormat: "dd/MM/yy")): TK_Vật phẩm sử dụng"
                
                let staffData = App.shared.staffInfo
                report = BaoCao(idnhanvien: staffData?.idnhanvien ?? "", tieude: title, noidung: reportContent, ngaytao: Date(), loaibaocao: 3, daxoa: 0, staff: staffData)
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
            if column == 0 {
                return 120
            } else if column == 1 {
                return 250
            }
            return 200
        default:
            break
        }
        return 0
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        switch reportType {
        case .income:
            return 4
        case .bestSeller:
            return 3
        case .stuffUsed:
            return 3
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
            return reportDatas.count + 1
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
                if yellowRow.contains(indexPath.row - 1) {
                    cell.backgroundColor = .yellow
                } else {
                    cell.backgroundColor = .white
                }
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
            if indexPath.row > 0, reportDatas[indexPath.row - 1][indexPath.column].lowercased() == "tổng" {
                startHeaderRow = indexPath.row
            }
            if indexPath.row == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                if indexPath.column == 0 {
                    cell.label.text = "Ngày"
                } else if indexPath.column == 1 {
                    cell.label.text = "Danh sách order"
                } else if indexPath.column == 2 {
                    cell.label.text = "Danh sách vật phẩm"
                }
                cell.label.textAlignment = .center
                cell.setNeedsLayout()

                return cell
            }  else if indexPath.row >= startHeaderRow ?? reportDatas.count + 1 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                cell.label.textAlignment = .center
                cell.label.text = reportDatas[indexPath.row - 1][indexPath.column]
                
                return cell
            } else {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.label.textAlignment = .center
                cell.label.text = reportDatas[indexPath.row - 1][indexPath.column]
                
                return cell
            }
            
        default:
            break
        }
        return nil
    }
}

extension CreateReportManagerViewController: SpreadsheetViewDelegate {
    
}
