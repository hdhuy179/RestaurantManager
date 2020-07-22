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
    
    private var tableSearchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Tìm kiếm..."
        searchController.hidesNavigationBarDuringPresentation = true
        //        searchController.searchResultsUpdater = self
        return searchController
    } ()
    
    private struct tableViewProperties {
        static let rowNibName = "StorageItemsTableViewCell"
        static let rowID = "rowID"
        static let rowHeight: CGFloat = 80.0
    }
    
    var importBill: [[PhieuNhap]] = []
    var exportBill: [[PhieuXuat]] = []
    var stuffLeft: [[PhieuNhap]] = []
    
    var currentImportBill: [[PhieuNhap]] = []
    var currentExportBill: [[PhieuXuat]] = []
    var currentStuffLeft: [[PhieuNhap]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupViews()
        fetchData()
    }
    
    private func setupViews() {
        
        tableSearchController.searchResultsUpdater = self
        tableSearchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = tableSearchController
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
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
                    let itemDate = String(item.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy") ?? "")
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
                self?.currentImportBill = self?.importBill ?? []
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
                var notExportedList: [PhieuXuat] = []
                var tempArray: [PhieuXuat] = []
                
                for item in datas {
                    if item.trangthai == 0 {
                        notExportedList.append(item)
                        continue
                    }
                    let itemDate = String(item.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy") ?? "")
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
                self?.exportBill.insert(notExportedList, at: 0)
                self?.currentExportBill = self?.exportBill ?? []
                counter += 1
                if counter == 2 {
                    self?.setupData()
                }
            }
        }
    }
    
    func setupData() {
        
        tableRefreshControl.endRefreshing()
        stuffLeft.removeAll()
        for importList in importBill {
            var temp: [PhieuNhap] = importList
            for (index, imp) in temp.enumerated() {
                for exportList in exportBill {
                    for exp in exportList {
                        if imp.idphieunhap == exp.idphieunhap && exp.trangthai == 1 {
                            temp[index].soluong -= exp.soluong
                        }
                    }
                }
            }
            temp.removeAll(where: { $0.soluong <= 0})
            if temp.isEmpty != true {
                stuffLeft.append(temp)
            }
        }
        currentStuffLeft = stuffLeft
        
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
        let present = PresentHandler()
        present.presentImportBillManagerVC(self, forStorager: true)
    }
}

extension StorageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if storageSegmentedControl.selectedSegmentIndex == 1 {
            return currentExportBill.count
        }
        if storageSegmentedControl.selectedSegmentIndex == 2 {
            return currentImportBill.count
        }
        return currentStuffLeft.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if storageSegmentedControl.selectedSegmentIndex == 1 {
            return currentExportBill[section].count
        }
        if storageSegmentedControl.selectedSegmentIndex == 2 {
            return currentImportBill[section].count
        }
        return currentStuffLeft[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if storageSegmentedControl.selectedSegmentIndex == 1 {
            if section == 0 {
                return currentExportBill[section].isEmpty == false ? "   Phiếu chưa xuất" : nil
            }
            return "   Ngày " + String(currentExportBill[section].first?.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy") ?? "")
        }
        if storageSegmentedControl.selectedSegmentIndex == 2 {
            return "   Ngày " + String(currentImportBill[section].first?.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy") ?? "")
        }
        return "   Ngày " + String(currentStuffLeft[section].first?.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy") ?? "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableViewProperties.rowID, for: indexPath) as? StorageItemsTableViewCell else {
            fatalError("StorageItemsTableViewCell: Can't dequeue for StorageItemsTableViewCell")
        }
        if storageSegmentedControl.selectedSegmentIndex == 0 {
            cell.configView(data: currentStuffLeft[indexPath.section][indexPath.item])
        } else if storageSegmentedControl.selectedSegmentIndex == 1 {
            
            var imp: PhieuNhap?
            for item in currentImportBill {
                imp = item.first { $0.idphieunhap == currentExportBill[indexPath.section][indexPath.item].idphieunhap}
                if imp != nil {
                    break
                }
            }
            
            cell.configView(data: currentExportBill[indexPath.section][indexPath.item], of: imp)
        } else if storageSegmentedControl.selectedSegmentIndex == 2 {
            cell.configView(data: currentImportBill[indexPath.section][indexPath.item])
        }
        return cell
    }
    
}

extension StorageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewProperties.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if storageSegmentedControl.selectedSegmentIndex == 0 {
            let presentHandler = PresentHandler()
            var imp: PhieuNhap?
            for item in currentImportBill {
                imp = item.first { $0.idphieunhap == currentStuffLeft[indexPath.section][indexPath.item].idphieunhap}
                if imp != nil {
                    break
                }
            }
            presentHandler.presentImportBillManagerVC(self, data: imp, forDetail: true)
        } else if storageSegmentedControl.selectedSegmentIndex == 1 {
            var imp: PhieuNhap?
            for item in importBill {
                imp = item.first { $0.idphieunhap == currentExportBill[indexPath.section][indexPath.item].idphieunhap}
                if imp != nil {
                    break
                }
            }
            let presentHandler = PresentHandler()
            presentHandler.presentExportBillManagerVC(self, data: currentExportBill[indexPath.section][indexPath.item], imp: imp, forShowDetails: true)
        } else if storageSegmentedControl.selectedSegmentIndex == 2 {
            let presentHandler = PresentHandler()
            presentHandler.presentImportBillManagerVC(self, data: self.currentImportBill[indexPath.section][indexPath.item], forDetail: true)
        }
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
                let alert = UIAlertController(title: "Xuất " + self.currentStuffLeft[indexPath.section][indexPath.item].tenvatpham, message: "Số lượng (\(self.currentStuffLeft[indexPath.section][indexPath.item].donvi)): ", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.keyboardType = .decimalPad
                }
                alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: { (action) in
                    guard let text = alert.textFields?.first?.text else { return }
                    if let soluong = Float(text), soluong > 0, soluong <= self.currentStuffLeft[indexPath.section][indexPath.item].soluong {
                        let impData = self.currentStuffLeft[indexPath.section][indexPath.item]
                        let exportData = PhieuXuat(idphieunhap: impData.idphieunhap, ngaytao: Date(), soluong: soluong, trangthai: 0, daxoa: 0)
                        PhieuXuat.createBill(data: exportData) { [weak self](err) in
                            if err == nil {
                                self?.showAlert(title: "Thông báo", message: "Tạo phiếu xuất \(soluong) \(self?.currentStuffLeft[indexPath.section][indexPath.item].donvi.lowercased() ?? "") \(self?.currentStuffLeft[indexPath.section][indexPath.item].tenvatpham.lowercased() ?? "") thành công.")
                            }
                            self?.fetchData()
                        }
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
            
            let lbHuy = currentExportBill[indexPath.section][indexPath.item].trangthai == 1 ? "Xóa" : "Hủy"
            
            let huy = UITableViewRowAction(style: .default, title: lbHuy) {(_, index) in
                PhieuXuat.deleteExportBill(data: self.currentExportBill[indexPath.section][indexPath.item]) { [weak self] (err) in
                    self?.fetchData()
                }
            }
            let xacnhan = UITableViewRowAction(style: .normal, title: "Xác nhận") { (_, index) in
                PhieuXuat.confirmExportBill(data: self.currentExportBill[indexPath.section][indexPath.item]) { [weak self] (err) in
                    self?.fetchData()
                }
            }
            xacnhan.backgroundColor = .systemGreen
            
            let traDu = UITableViewRowAction(style: .normal, title: "Trả dư") { (_, index) in
                var imp: PhieuNhap?
                for item in self.importBill {
                    imp = item.first { $0.idphieunhap == self.currentExportBill[indexPath.section][indexPath.item].idphieunhap}
                    if imp != nil {
                        break
                    }
                }
                let alert = UIAlertController(title: "Trả " + (imp?.tenvatpham ?? ""), message: "Số lượng (\(imp?.donvi ?? "")): ", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.keyboardType = .decimalPad
                }
                alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: { (action) in
                    guard let text = alert.textFields?.first?.text else { return }
                    if let soluong = Float(text), soluong > 0, soluong <= self.currentExportBill[indexPath.section][indexPath.item].soluong {
                        var impData = self.currentExportBill[indexPath.section][indexPath.item]
                        impData.soluong -= soluong
                        PhieuXuat.createBill(data: impData) { [weak self](err) in
                            self?.showAlert(title: "Thông báo", message: "Trả \(soluong) \(imp?.donvi.lowercased() ?? "") \(imp?.tenvatpham.lowercased() ?? "") thành công.")
                            self?.fetchData()
                        }
                    } else {
                        let subAlert = UIAlertController(title: "Lỗi", message: "Hãy kiểm tra lại số lượng", preferredStyle: .alert)
                        subAlert.addAction(UIAlertAction(title: "Oke", style: .destructive, handler: nil))
                        self.present(subAlert, animated: true, completion: nil)
                    }
                }))
                self.present(alert, animated: true)
            }
            
            if currentExportBill[indexPath.section][indexPath.item].trangthai == 1 {
                return [huy, traDu]
            }
            return [huy, xacnhan]
        case 2:
            let xoa = UITableViewRowAction(style: .default, title: "Xóa") {(_, index) in
                PhieuNhap.deleteExportBill(data: self.currentImportBill[indexPath.section][indexPath.item]) { [weak self](err) in
                    self?.fetchData()
                }
            }
            let sua = UITableViewRowAction(style: .normal, title: "Sửa") { (_, index) in
               let presentHandler = PresentHandler()
                presentHandler.presentImportBillManagerVC(self, data: self.currentImportBill[indexPath.section][indexPath.item], forDetail: false, forStorager: true)
            }
            return [xoa, sua]
        default:
            return []
        }
    }
}

extension StorageViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text?.lowercased().trimmed else { return }
        
        if text.isEmpty == true {
            storageTableView.refreshControl = tableRefreshControl
            switch storageSegmentedControl.selectedSegmentIndex {
            case 0:
                currentStuffLeft = stuffLeft
            case 1:
                currentExportBill = exportBill
            case 2:
                currentImportBill = importBill
            default:
                break
            }
            storageTableView.reloadData()
            return
        }
        storageTableView.refreshControl = nil
        switch storageSegmentedControl.selectedSegmentIndex {
        case 0:
            currentStuffLeft.removeAll()
            for item in stuffLeft {
                let list = item.filter({$0.tenvatpham.lowercased().contains(text) || $0.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy").lowercased().contains(text) ?? false || $0.maphieu.lowercased().contains(text) || $0.creatorStaff?.tennhanvien.lowercased().contains(text) ?? false})
                if list.isEmpty == false {
                    currentStuffLeft.append(list)
                }
            }
        case 1:
            currentExportBill.removeAll()
            for item in exportBill {
                
                let list = item.filter({
                    let currentItem = $0
                    var imp: PhieuNhap?
                    for item in currentImportBill {
                        imp = item.first { $0.idphieunhap == currentItem.idphieunhap}
                        if imp != nil {
                            break
                        }
                    }
                    return (imp?.tenvatpham.lowercased().contains(text) ?? false || $0.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy").lowercased().contains(text) ?? false || imp?.maphieu.lowercased().contains(text) ?? false || $0.creatorStaff?.tennhanvien.lowercased().contains(text) ?? false)})
                if list.isEmpty == false {
                    currentExportBill.append(list)
                }
            }
        case 2:
            currentImportBill.removeAll()
            for item in importBill {
                let list = item.filter({$0.tenvatpham.lowercased().contains(text) || $0.ngaytao?.convertToString(withDateFormat: "dd-MM-yyyy").lowercased().contains(text) ?? false || $0.maphieu.lowercased().contains(text) || $0.creatorStaff?.tennhanvien.lowercased().contains(text) ?? false})
                if list.isEmpty == false {
                    currentImportBill.append(list)
                }
            }
        default:
            break
        }
        
        storageTableView.reloadData()
    }
}
