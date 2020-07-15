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
    
    private var tableSearchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Tìm Order..."
        searchController.hidesNavigationBarDuringPresentation = true
        //        searchController.searchResultsUpdater = self
        return searchController
    } ()
    
    private lazy var tableRefreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(fetchAllTodayOrder), for: .valueChanged)
        return refresh
    } ()
    
    private struct tableViewProperties {
        static let rowNibName = "KitchenOrderTableViewCell"
        static let rowID = "rowID"
        static let rowHeight: CGFloat = 70.0
    }
    
    var cookedOder: [Order] = []
    var uncookedOrder: [Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        fetchAllTodayOrder()
        
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) {_ in
            self.fetchAllTodayOrder()
        }
    }
    
    deinit {
        logger()
    }
    
    @objc func fetchAllTodayOrder() {
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
                self?.cookedOder.sort{ $0.ngaytao?.timeIntervalSince1970 ?? 0 < $1.ngaytao?.timeIntervalSince1970 ?? 0}
                self?.cookedOder.sort{ $0.trangthai < $1.trangthai}
                self?.uncookedOrder.sort{ $0.ngaytao?.timeIntervalSince1970 ?? 0 < $1.ngaytao?.timeIntervalSince1970 ?? 0}
                self?.uncookedOrder.sort{ $0.trangthai < $1.trangthai}
                
            }
            self?.tableRefreshControl.endRefreshing()
            self?.orderTableView.reloadData()
        }
        
    }
    
    private func setupViews() {
//        checkStaffAuthorities()
        navigationItem.hidesSearchBarWhenScrolling = true
        tableSearchController.searchResultsUpdater = self
        tableSearchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = tableSearchController
        
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
                return "   " + "Đang đợi"
            }
            return "   " + "Đang nấu"
        }
        if section == 0 {
            return "   " + "Đã nấu"
        }
        return "   " + "Đã hoàn thành"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if kitchenSegmentedControl.selectedSegmentIndex == 0 {
            if section == 0 {
                return uncookedOrder.filter{ $0.trangthai == 0}.count
            }
            return uncookedOrder.filter{ $0.trangthai == 1}.count
        }
        if section == 0 {
            return cookedOder.filter{ $0.trangthai == 2}.count
        }
        return cookedOder.filter{ $0.trangthai == 3}.count
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
            cell.order = uncookedOrder[indexPath.item + addition]
        } else if kitchenSegmentedControl.selectedSegmentIndex == 1 {
            var addition = 0
            if indexPath.section == 1 {
                addition = tableView.numberOfRows(inSection: 0)
            }
            cell.order = cookedOder[indexPath.item + addition]
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
        return false
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.section == 0, kitchenSegmentedControl.selectedSegmentIndex == 0 {
            return nil
        }
        
        let hoantac = UITableViewRowAction(style: .default, title: "Hoàn tác") {(_, index) in
            
            var order: Order? = nil
            var addition = 0
            
            if self.kitchenSegmentedControl.selectedSegmentIndex == 1 {
                var addition = 0
                if indexPath.section == 1 {
                    addition = tableView.numberOfRows(inSection: 0)
                }
                order = self.cookedOder[indexPath.item + addition]
            } else {
                if indexPath.section == 1 {
                    addition = tableView.numberOfRows(inSection: 0)
                }
                
                order = self.uncookedOrder[indexPath.item + addition]
            }
            if var order = order, order.trangthai >= 0{
                order.trangthai = order.trangthai - 1
                order.updateOrder(forOrder: order) { error in
                }
            }
            self.fetchAllTodayOrder()
        }
        return [hoantac]
    }
}

extension KitchenViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
}
