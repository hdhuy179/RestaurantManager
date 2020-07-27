//
//  KitchenViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 2/6/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class KitchenViewController: UIViewController {
    
    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var kitchenSegmentedControl: UISegmentedControl!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    private var tableSearchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Tìm Order..."
        searchController.hidesNavigationBarDuringPresentation = true
        //        searchController.searchResultsUpdater = self
        return searchController
    } ()
    
    private lazy var tableRefreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        return refresh
    } ()
    
    private struct tableViewProperties {
        static let rowNibName = "KitchenOrderTableViewCell"
        static let rowID = "rowID"
        static let rowHeight: CGFloat = 70.0
    }
    
    var cookedOder: [Order] = []
    var uncookedOrder: [Order] = []
    
    var currentCookedOrder: [Order] = []
    var currentUncookedOrder: [Order] = []
    
    var tableData: [BanAn] = []
    var billData: [HoaDon] = []
    
    var autoFetchTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        fetchData()
        
        autoFetchTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) {_ in
            self.fetchData()
        }
    }
    
    deinit {
        logger()
    }
    
    var lastUpdateTimer: Timer?
    
    func orderStateUpdated() {
        
        autoFetchTimer?.invalidate()
        lastUpdateTimer?.invalidate()
        
        lastUpdateTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {_ in
            self.fetchData()
            self.lastUpdateTimer = nil
            self.autoFetchTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) {_ in
                self.fetchData()
            }
        }
    }
    
    @objc func fetchData() {
        var counter = 0
        let maxCounter = 3
        Order.fetchKitchenData { [weak self] orders, error in
            self?.cookedOder.removeAll()
            self?.uncookedOrder.removeAll()
            if let orders = orders {
                for order in orders {
                    if order.trangthai == 0 || order.trangthai == 1 {
                        self?.uncookedOrder.append(order)
                    } else if order.trangthai == 2 || order.trangthai == 3 {
                        self?.cookedOder.append(order)
                    }
                }
                self?.cookedOder.sort{ $0.ngaytao?.timeIntervalSince1970 ?? 0 > $1.ngaytao?.timeIntervalSince1970 ?? 0}
                self?.cookedOder.sort{ $0.trangthai < $1.trangthai}
                self?.uncookedOrder.sort{ $0.ngaytao?.timeIntervalSince1970 ?? 0 < $1.ngaytao?.timeIntervalSince1970 ?? 0}
                self?.uncookedOrder.sort{ $0.trangthai < $1.trangthai}
                
                self?.currentCookedOrder = self?.cookedOder ?? []
                self?.currentUncookedOrder = self?.uncookedOrder ?? []
            }
            counter += 1
            if counter == maxCounter {
                self?.setupData()
            }
        }
        
        BanAn.fetchAllData { [weak self] (datas, error) in
            if let datas = datas  {
                self?.tableData = datas
            }
            counter += 1
            if counter == maxCounter {
                self?.setupData()
            }
        }
        
        HoaDon.fetchTodayBill { [weak self] (datas, err) in
            if let datas = datas {
                self?.billData = datas
            }
            counter += 1
            if counter == maxCounter {
                self?.setupData()
            }
        }
        
    }
    
    func setupData() {
        tableRefreshControl.endRefreshing()
        orderTableView.reloadData()
        checkBadgeValue()
    }
    
    func checkBadgeValue() {
        if App.shared.staffInfo?.quyen != 1 && App.shared.staffInfo?.quyen != 4 {
            return
        }
        
        let badgeValue = uncookedOrder.filter({ $0.trangthai == 0 }).count
        if badgeValue == 0 {
            self.tabBarController?.tabBar.items?[1].badgeValue = nil
            return
        }
        self.tabBarController?.tabBar.items?[1].badgeValue = String(badgeValue)
    }
    
    private func setupViews() {
        if App.shared.staffInfo?.quyen != 1 && App.shared.staffInfo?.quyen != 4 {
            btnMenu.isEnabled = false
            btnMenu.tintColor = .lightGray
        }
        addEndEditingTapGuesture()
        tableSearchController.searchResultsUpdater = self
        tableSearchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = tableSearchController
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        orderTableView.refreshControl = tableRefreshControl
        orderTableView.dataSource = self
        orderTableView.delegate = self
        
        orderTableView.register(UINib(nibName: tableViewProperties.rowNibName, bundle: nil), forCellReuseIdentifier: tableViewProperties.rowID)
    }
    
    private func checkStaffAuthorities() {
        if kitchenSegmentedControl.numberOfSegments >= 2 {
            for index in 1..<kitchenSegmentedControl.numberOfSegments {
                kitchenSegmentedControl.setEnabled(false, forSegmentAt: index)
            }
        }
    }
    
    @IBAction func kitchenSegmentedControlValueChanged(_ sender: Any) {
        orderTableView.reloadData()
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        let handler = PresentHandler()
        handler.presentMenuVC(self)
    }
}

extension KitchenViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if kitchenSegmentedControl.selectedSegmentIndex == 0 {
            if section == 0 {
                if currentUncookedOrder.filter({ $0.trangthai == 0}).isEmpty == true {
                    return nil
                }
                return "   " + "Đang đợi"
            }
            if currentUncookedOrder.filter({ $0.trangthai == 1}).isEmpty == true {
                return nil
            }
            return "   " + "Đang nấu"
        }
        if section == 0 {
            if currentCookedOrder.filter({ $0.trangthai == 2}).isEmpty == true {
                return nil
            }
            return "   " + "Đã nấu"
        }
        if currentCookedOrder.filter({ $0.trangthai == 3}).isEmpty == true {
            return nil
        }
        return "   " + "Đã hoàn thành"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if kitchenSegmentedControl.selectedSegmentIndex == 0 {
            if section == 0 {
                return currentUncookedOrder.filter{ $0.trangthai == 0}.count
            }
            return currentUncookedOrder.filter{ $0.trangthai == 1}.count
        }
        if section == 0 {
            return currentCookedOrder.filter{ $0.trangthai == 2}.count
        }
        return currentCookedOrder.filter{ $0.trangthai == 3}.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableViewProperties.rowID, for: indexPath) as? KitchenOrderTableViewCell else {
            fatalError("KitchenViewController: Can't dequeue for orderTableViewCell")
        }
        if kitchenSegmentedControl.selectedSegmentIndex == 0 {
            var addition = 0
            if indexPath.section == 1 {
                addition = tableView.numberOfRows(inSection: 0)
            }
            let bill = billData.first(where: { $0.idhoadon == currentUncookedOrder[indexPath.item + addition].idhoadon})
            let table = tableData.first(where: { $0.idbanan == bill?.idbanan})
            cell.configView(order: currentUncookedOrder[indexPath.item + addition], table: table)
        } else if kitchenSegmentedControl.selectedSegmentIndex == 1 {
            var addition = 0
            if indexPath.section == 1 {
                addition = tableView.numberOfRows(inSection: 0)
            }
            let bill = billData.first(where: { $0.idhoadon == currentCookedOrder[indexPath.item + addition].idhoadon})
            let table = tableData.first(where: { $0.idbanan == bill?.idbanan})
            cell.configView(order: currentCookedOrder[indexPath.item + addition], table: table)
        }
        cell.delegate = self
        return cell
    }
    
    
}

extension KitchenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewProperties.rowHeight
//        return UIScreen.main.bounds.height/12
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if App.shared.staffInfo?.quyen == 5 {
             return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if App.shared.staffInfo?.quyen == 1 || App.shared.staffInfo?.quyen == 2 || App.shared.staffInfo?.quyen == 3 || App.shared.staffInfo?.quyen == 4 {
            let present = PresentHandler()
            var table: BanAn?
            if kitchenSegmentedControl.selectedSegmentIndex == 0 {
                var addition = 0
                if indexPath.section == 1 {
                    addition = tableView.numberOfRows(inSection: 0)
                }
                let bill = billData.first(where: { $0.idhoadon == currentUncookedOrder[indexPath.item + addition].idhoadon})
                table = tableData.first(where: { $0.idbanan == bill?.idbanan})
                table?.bill = bill
            } else if kitchenSegmentedControl.selectedSegmentIndex == 1 {
                var addition = 0
                if indexPath.section == 1 {
                    addition = tableView.numberOfRows(inSection: 0)
                }
                let bill = billData.first(where: { $0.idhoadon == currentCookedOrder[indexPath.item + addition].idhoadon})
                table = tableData.first(where: { $0.idbanan == bill?.idbanan})
                table?.bill = bill
            }
            if table?.bill?.dathanhtoan == 1 {
                present.presentBillManagerVC(self, bill: table?.bill, forBillHistory: true)
                return
            }
            present.presentTableBillDetailVC(self, table: table)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if App.shared.staffInfo?.quyen != 1 && App.shared.staffInfo?.quyen != 4 {
            return nil
        }
        
        if indexPath.section == 0, kitchenSegmentedControl.selectedSegmentIndex == 0 {
            return nil
        }
        
        if kitchenSegmentedControl.selectedSegmentIndex == 0 {
            var addition = 0
            if indexPath.section == 1 {
                addition = tableView.numberOfRows(inSection: 0)
            }
            let bill = billData.first(where: { $0.idhoadon == currentUncookedOrder[indexPath.item + addition].idhoadon})
            if bill?.dathanhtoan == 1 {
                return nil
            }

        } else if kitchenSegmentedControl.selectedSegmentIndex == 1 {
            var addition = 0
            if indexPath.section == 1 {
                addition = tableView.numberOfRows(inSection: 0)
            }
            let bill = billData.first(where: { $0.idhoadon == currentCookedOrder[indexPath.item + addition].idhoadon})
            if bill?.dathanhtoan == 1 {
                return nil
            }
        }
        
        let hoantac = UITableViewRowAction(style: .default, title: "Hoàn tác") {(_, index) in
            
            var order: Order? = nil
            var addition = 0
            
            if self.kitchenSegmentedControl.selectedSegmentIndex == 1 {
                var addition = 0
                if indexPath.section == 1 {
                    addition = tableView.numberOfRows(inSection: 0)
                }
                order = self.currentCookedOrder[indexPath.item + addition]
            } else {
                if indexPath.section == 1 {
                    addition = tableView.numberOfRows(inSection: 0)
                }
                
                order = self.currentUncookedOrder[indexPath.item + addition]
            }
            if var order = order, order.trangthai >= 0 {
                order.trangthai = order.trangthai - 1
                order.updateOrder(forOrder: order) { error in
                }
            }
            self.fetchData()
        }
        return [hoantac]
    }
}

extension KitchenViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard var text = searchController.searchBar.text else { return }
        
        text = text.lowercased()
        if let _ = text.lowercased().range(of: "bàn") {
            text = text.replacingOccurrences(of: "bàn", with: "")
        } else if let  _ = text.lowercased().range(of: "ban") {
            text = text.replacingOccurrences(of: "ban", with: "")
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty == true {
            orderTableView.refreshControl = tableRefreshControl
        }
        if text.isEmpty == false {
            orderTableView.refreshControl = nil
//            currentTableData = tableData.filter { $0.sobanan?.range(of: text) != nil}
            if kitchenSegmentedControl.selectedSegmentIndex == 0 {
//                var tempArr = uncookedOrder
                currentUncookedOrder.removeAll()
                let list = tableData.filter({ $0.sobanan?.contains(text) ?? false })
                if list.isEmpty == false {
                    for tableItem in list {
                        for item in uncookedOrder {
                            let bill = billData.first(where: { $0.idhoadon == item.idhoadon})
                            let table = tableData.first(where: { $0.idbanan == bill?.idbanan})
                            if table?.idbanan == tableItem.idbanan {
                                currentUncookedOrder.append(item)
                            }
                        }
                    }
                    
                } else {
                    for item in uncookedOrder {
                        if item.dish?.tenmonan.lowercased().contains(text) ?? false {
                            currentUncookedOrder.append(item)
                        }
                    }
                }
            } else if kitchenSegmentedControl.selectedSegmentIndex == 1 {
                currentCookedOrder.removeAll()
                let list = tableData.filter({ $0.sobanan?.contains(text) ?? false })
                if list.isEmpty == false {
                    for tableItem in list {
                        for item in cookedOder {
                            let bill = billData.first(where: { $0.idhoadon == item.idhoadon})
                            let table = tableData.first(where: { $0.idbanan == bill?.idbanan})
                            if table?.idbanan == tableItem.idbanan {
                                currentCookedOrder.append(item)
                            }
                        }
                    }
                    
                } else {
                    for item in cookedOder {
                        if item.dish?.tenmonan.lowercased().contains(text) ?? false {
                            currentCookedOrder.append(item)
                        }
                    }
                }
            }
        } else {
            currentUncookedOrder = uncookedOrder
            currentCookedOrder = cookedOder
        }
        orderTableView.reloadData()
    }
    
}
