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
    
    var report: BaoCao!
    
    var reportDatas: [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
        splitData()
    }
    
    func setupView() {
        ssvReportContent.dataSource = self
        ssvReportContent.delegate = self
        
        ssvReportContent.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        ssvReportContent.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
    }
    
    func splitData() {
        
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
        return 100
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
//        if vertically {
//            return checkInList.count + 1
//        }
        return 20
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
//        if vertically {
//            return Constants.recordXMLParserProperties.allCases.count
//        }
//        return checkInList.count + 1
        return 20
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
//        if vertically {
//            if indexPath.column == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
//                cell.label.text = Constants.recordXMLParserProperties.allCases[indexPath.row].rawValue
//                cell.setNeedsLayout()
//
                return cell
//            } else {
//                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
//                let data = checkInList[indexPath.column - 1]
//
//                if data.absent == true {
//                    cell.backgroundColor = .red
//                } else if data.late != nil {
//                    cell.backgroundColor = .yellow
//                } else {
//                    cell.backgroundColor = .white
//                }
//
//                switch Constants.recordXMLParserProperties.allCases[indexPath.row] {
//                case .date:
//                    cell.label.text = data.date?.toString()
//                case .timetable:
//                    cell.label.text = data.timeTable
//                case .starttime:
//                    cell.label.text = data.startTime
//                case .endtime:
//                    cell.label.text = data.endTime
//                case .clockin:
//                    cell.label.text = data.clockIn
//                case .late:
//                    cell.label.text = data.late?.toHoursString()
//                case .absent:
//                    cell.label.text = data.absent == true ? "True" : "False"
//                case .normal:
//                    cell.label.text = String(data.normal ?? 0)
//                }
//                return cell
//            }
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
