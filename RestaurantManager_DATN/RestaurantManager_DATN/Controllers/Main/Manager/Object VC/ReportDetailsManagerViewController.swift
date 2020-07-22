//
//  ReportDetailsManagerViewController.swift
//  RestaurantManager_DATN
//
//  Created by HuyHoangDinh on 7/17/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class ReportDetailsManagerViewController: UIViewController {

    @IBOutlet weak var lbReportTitle: UILabel!
    @IBOutlet weak var ssvReportContent: SpreadsheetView!
    @IBOutlet weak var btnNAV: RaisedButton!
    
    weak var delegate: ManagerDataViewController?
    
    var reportType: ReportType?
    
    var report: BaoCao!
    
    var reportDatas: [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
        setupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.fetchData()
    }
    
    func setupView() {
        if report.daxoa == 1 {
            btnNAV.setTitle("Khôi phục", for: .normal)
        }
        ssvReportContent.dataSource = self
        ssvReportContent.delegate = self
        ssvReportContent.stickyRowHeader = true
        
        ssvReportContent.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        ssvReportContent.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
    }
    
    func setupData() {
        switch report.loaibaocao {
        case 1:
            reportType = .income
        case 2:
            reportType = .bestSeller
        case 3:
            reportType = .stuffUsed
        default:
            return
        }
        let reportContent = report.noidung.replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\t", with: "\t")
        let splited = reportContent.split { $0 == "\n"}
        for item in splited {
            let item = String(item)
            reportDatas.append(item.split { $0 == "\t"}.map(String.init))
        }
//        switch reportType {
//        case .income:
//            break
//        case .bestSeller:
//            let reportContent = report.noidung.replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\t", with: "\t")
//            let splited = reportContent.split { $0 == "\n"}
//            for item in splited {
//                let item = String(item)
//                reportDatas.append(item.split { $0 == "\t"}.map(String.init))
//            }
//        case .stuffUsed:
//            break
//        default:
//            break
//        }
        let attributed = NSMutableAttributedString()
        let title = NSAttributedString(string: report.tieude, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)])
        let subtitle = NSAttributedString(string: "\n Người tạo: \(report.staff?.tennhanvien ?? "")", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)])
        attributed.append(title)
        attributed.append(subtitle)
        lbReportTitle.attributedText = attributed//report.tieude + "\n Người tạo: \(report.staff?.tennhanvien ?? "")"
        
        ssvReportContent.reloadData()
    }
    
    @IBAction func btnNAVWasTapped(_ sender: Any) {
        let will = report?.daxoa == 0 ? 1 : 0
        let message = will == 0 ? "Bạn có chắc chắn muốn khôi phục dữ liệu không" : "Bạn có chắc chắn muốn xóa dữ liệu không"
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        let xacnhan = UIAlertAction(title: "Xác nhận", style: .default) { (_) in
            self.btnNAV.isEnabled = false
            self.report.daxoa = will
            BaoCao.saveReport(data: self.report) { [weak self] (err) in
                self?.btnNAV.isEnabled = true
                if err == nil {
                    self?.dismiss(animated: true)
                }
            }
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
extension ReportDetailsManagerViewController: SpreadsheetViewDataSource {
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow column: Int) -> CGFloat {
        return 50
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
//    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
//        if reportType == .income {
//            return 1
//        }
//        return 0
//    }
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
            return UIScreen.main.bounds.width - 50 - 45 - 90 - 5 + 20
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

extension ReportDetailsManagerViewController: SpreadsheetViewDelegate {
    
}
