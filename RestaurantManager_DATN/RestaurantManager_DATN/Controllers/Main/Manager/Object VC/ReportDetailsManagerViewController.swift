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
    
    func setupView() {
        ssvReportContent.dataSource = self
        ssvReportContent.delegate = self
        
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
        ssvReportContent.reloadData()
    }
    
    @IBAction func btnNAVWasTapped(_ sender: Any) {
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
extension ReportDetailsManagerViewController: SpreadsheetViewDataSource {
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow column: Int) -> CGFloat {
        return 50
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return UIScreen.main.bounds.width - 30//400
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
//        if vertically {
//            return Constants.recordXMLParserProperties.allCases.count
//        }
//        return checkInList.count + 1
        return reportDatas.count + 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
//        if vertically {
            if indexPath.row == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                cell.label.text = "Danh sách món bán chạy nhất:"
                cell.setNeedsLayout()

                return cell
            } else {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.label.text = reportDatas[indexPath.row - 1][indexPath.column]
                
                return cell
            }
//        }
//        if indexPath.row == 0 {
//            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
//            cell.label.text = Constants.recordXMLParserProperties.allCases[indexPath.column].rawValue
//            cell.setNeedsLayout()
//
//            return cell
//        } else {
//            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
//            let data = checkInList[indexPath.row - 1]
//            switch Constants.recordXMLParserProperties.allCases[indexPath.column] {
//            case .date:
//                cell.label.text = data.date?.toString()
//            case .timetable:
//                cell.label.text = data.timeTable
//            case .starttime:
//                cell.label.text = data.startTime
//            case .endtime:
//                cell.label.text = data.endTime
//            case .clockin:
//                cell.label.text = data.clockIn
//            case .late:
//                cell.label.text = data.late?.toHoursString()
//            case .absent:
//                cell.label.text = data.absent == true ? "True" : "False"
//            case .normal:
//                cell.label.text = String(data.normal ?? 0)
//            }
//            return cell
//        }
    }
}

extension ReportDetailsManagerViewController: SpreadsheetViewDelegate {
    
}

extension ReportDetailsManagerViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
//        if elementName.lowercased() == Constants.record {
//            checkInList.append(CheckInModel())
//            return
//        }
//
//        self.elementName = elementName.lowercased()
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
//        let recordProperties = Constants.recordXMLParserProperties.self
//        let userInfoProperties = Constants.userInfoXMLParserProperties.self
//
//        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
//        switch elementName {
//        case userInfoProperties.username.getString():
//            lbStaffName.text = data
//        case userInfoProperties.department.getString():
//            lbStaffDepartment.text = data
//        case recordProperties.date.getString():
//            checkInList.last?.date = data.toDate(dateFormat: Constants.recordDateFormat)
//        case recordProperties.timetable.getString():
//            checkInList.last?.timeTable = data
//        case recordProperties.starttime.getString():
//            checkInList.last?.startTime = data
//        case recordProperties.endtime.getString():
//            checkInList.last?.endTime = data
//        case recordProperties.clockin.getString():
//            checkInList.last?.clockIn = data
//        case recordProperties.late.getString():
//            checkInList.last?.late = data.hoursToTimeInterval()
//        case recordProperties.absent.getString():
//            checkInList.last?.absent = data.lowercased() != "false"
//        case recordProperties.normal.getString():
//            checkInList.last?.normal = (data as NSString).floatValue
//        default: break
//        }
    }
}
