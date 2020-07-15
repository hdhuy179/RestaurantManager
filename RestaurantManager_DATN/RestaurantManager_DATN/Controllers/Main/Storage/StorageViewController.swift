//
//  StorageViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 2/8/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class StorageViewController: UIViewController {

    @IBOutlet weak var storageTableView: UITableView!
    @IBOutlet weak var storageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var btnCreateBill: UIBarButtonItem!
    
    private lazy var tableRefreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        return refresh
    } ()
    
    private struct tableViewProperties {
        static let rowNibName = "StorageItemsTableViewCell"
        static let rowID = "rowID"
        static let rowHeight: CGFloat = 80.0
    }
    
    var importBill: [[PhieuNhap]] = []
    var exportBill: [[PhieuXuat]] = []
    var currentStuff: [[PhieuNhap]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupViews()
        fetchData()
    }
    
    private func setupViews() {
//        checkStaffAuthorities()
        btnCreateBill.isEnabled = false
        btnCreateBill.tintColor = .clear
        
        storageTableView.refreshControl = tableRefreshControl
        storageTableView.dataSource = self
        storageTableView.delegate = self
        
        storageTableView.register(UINib(nibName: tableViewProperties.rowNibName, bundle: nil), forCellReuseIdentifier: tableViewProperties.rowID)
    }
    
    @objc func fetchData() {
        var counter = 0
        PhieuNhap.fetchAllDataAvailable { [weak self](datas, error) in
            if let datas = datas {
                self?.importBill.removeAll()
                let datas = datas.sorted {
                    $0.ngaytao ?? Date() > $1.ngaytao ?? Date()
                }
                var date: String?
                var tempArray: [PhieuNhap] = []
                
                for item in datas {
                    let itemDate = String(item.ngaytao?.convertToString().dropLast(9) ?? "")
                    if date != itemDate {
                        if tempArray.isEmpty == false {
                            self?.importBill.append(tempArray)
                        }
                        tempArray.removeAll()
                        date = itemDate
                        tempArray.append(item)
                    } else {
                        tempArray.append(item)
                    }
                }
                self?.importBill.append(tempArray)
                counter += 1
                if counter == 2 {
                    self?.setupData()
                }
                
            }
        }
        
        PhieuXuat.fetchAllDataAvailable { [weak self](datas, error) in
            if let datas = datas {
                self?.exportBill.removeAll()
                
                let datas = datas.sorted {
                    $0.ngaytao ?? Date() > $1.ngaytao ?? Date()
                }
                
                var date: String?
                var tempArray: [PhieuXuat] = []
                
                for item in datas {
                    let itemDate = String(item.ngaytao?.convertToString().dropLast(9) ?? "")
                    if date != itemDate {
                        if tempArray.isEmpty == false {
                            self?.exportBill.append(tempArray)
                        }
                        tempArray.removeAll()
                        date = itemDate
                        tempArray.append(item)
                    } else {
                        tempArray.append(item)
                    }
                }
                self?.exportBill.append(tempArray)
                counter += 1
                if counter == 2 {
                    self?.setupData()
                }
                
                counter += 1
                if counter == 2 {
                    self?.setupData()
                }
            }
        }
    }
    
    func setupData() {
        
        tableRefreshControl.endRefreshing()
        currentStuff.removeAll()
        for importList in importBill {
            var temp: [PhieuNhap] = importList
            for (index, imp) in importList.enumerated() {
                for exportList in exportBill {
                    for exp in exportList {
                        if imp.idnhieunhap == exp.idphieunhap && exp.trangthai == 1 {
                            temp[index].soluong -= exp.soluong
                        }
                    }
                }
            }
            currentStuff.append(temp)
        }
        
        storageTableView.reloadData()
    }
    
    deinit {
        logger()
    }
    
    private func checkStaffAuthorities() {
        if storageSegmentedControl.numberOfSegments >= 2 {
            for index in 1..<storageSegmentedControl.numberOfSegments {
                storageSegmentedControl.setEnabled(false, forSegmentAt: index)
            }
        }
    }
    
    @IBAction func swChangeValue(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 2 {
            btnCreateBill.isEnabled = true
            btnCreateBill.tintColor = .black
        } else {
            btnCreateBill.isEnabled = false
            btnCreateBill.tintColor = .clear
        }
        storageTableView.reloadData()
    }
    
    @IBAction func btnCreateBillTapped(_ sender: Any) {
    }
}

extension StorageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if storageSegmentedControl.selectedSegmentIndex == 1 {
            return exportBill.count
        }
        if storageSegmentedControl.selectedSegmentIndex == 2 {
            return importBill.count
        }
        return currentStuff.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if storageSegmentedControl.selectedSegmentIndex == 1 {
            return exportBill[section].count
        }
        if storageSegmentedControl.selectedSegmentIndex == 2 {
            return importBill[section].count
        }
        return currentStuff[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if storageSegmentedControl.selectedSegmentIndex == 1 {
            return "   " + String(exportBill[section].first?.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy") ?? "")
        }
        if storageSegmentedControl.selectedSegmentIndex == 2 {
            return "   " + String(importBill[section].first?.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy") ?? "")
        }
        return "   " + String(currentStuff[section].first?.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy") ?? "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableViewProperties.rowID, for: indexPath) as? StorageItemsTableViewCell else {
            fatalError("StorageItemsTableViewCell: Can't dequeue for StorageItemsTableViewCell")
        }
        if storageSegmentedControl.selectedSegmentIndex == 0 {
            cell.configView(data: currentStuff[indexPath.section][indexPath.item])
        } else if storageSegmentedControl.selectedSegmentIndex == 1 {
            
            var imp: PhieuNhap?
            for item in importBill {
                imp = item.first { $0.idnhieunhap == exportBill[indexPath.section][indexPath.item].idphieunhap}
                if imp != nil {
                    break
                }
            }
            
            cell.configView(data: exportBill[indexPath.section][indexPath.item], of: imp)
        } else if storageSegmentedControl.selectedSegmentIndex == 2 {
            cell.configView(data: importBill[indexPath.section][indexPath.item])
        }
        return cell
    }
    
}

extension StorageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewProperties.rowHeight
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        var state = 0
        if storageSegmentedControl.selectedSegmentIndex == 1 {
            state = 1
        }
        if storageSegmentedControl.selectedSegmentIndex == 2 {
            state = 2
        }
        
        switch state {
        case 0:
            let xuatKho = UITableViewRowAction(style: .normal, title: "Xuất kho") { (_, index) in
                let alert = UIAlertController(title: self.currentStuff[indexPath.section][indexPath.item].tenvatpham, message: "Số lượng(\(self.currentStuff[indexPath.section][indexPath.item].donvi)): ", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.keyboardType = .decimalPad
                }
                alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: { (action) in
                    guard let text = alert.textFields?.first?.text else { return }
                    if let soluong = Float(text), soluong > 0, soluong <= self.currentStuff[indexPath.section][indexPath.item].soluong {
                        
                    } else {
                        let subAlert = UIAlertController(title: "Lỗi", message: "Hãy kiểm tra lại số lượng", preferredStyle: .alert)
                        subAlert.addAction(UIAlertAction(title: "Oke", style: .destructive, handler: nil))
                        self.present(subAlert, animated: true, completion: nil)
                    }
                }))
                self.present(alert, animated: true)
            }
            xuatKho.backgroundColor = .systemGreen
            return [xuatKho]
        case 1:
            
            let lbHuy = exportBill[indexPath.section][indexPath.item].trangthai == 1 ? "Xóa" : "Hủy"
            
            let huy = UITableViewRowAction(style: .default, title: lbHuy) {(_, index) in
                 
            }
            let xacnhan = UITableViewRowAction(style: .normal, title: "Xác nhận") { (_, index) in
               
            }
            xacnhan.backgroundColor = .systemGreen
            
            if exportBill[indexPath.section][indexPath.item].trangthai == 1 {
                return [huy]
            }
            return [huy, xacnhan]
        case 2:
            let xoa = UITableViewRowAction(style: .default, title: "Xóa") {(_, index) in
                 
            }
            let sua = UITableViewRowAction(style: .normal, title: "Sửa") { (_, index) in
               
            }
            return [xoa, sua]
        default:
            return []
        }
    }
}
