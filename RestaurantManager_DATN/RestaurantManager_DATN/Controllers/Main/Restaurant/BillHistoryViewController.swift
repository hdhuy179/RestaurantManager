//
//  TakeawayViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 2/8/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class BillHistoryViewController: UIViewController {

    @IBOutlet weak var billTableView: UITableView!
    
    private struct tableViewProperties {
        static let rowNibName = "BillTableViewCell"
        static let rowID = "BillTableViewCell"
        static let rowHeight: CGFloat = 70.0
    }
    
    var bills: [HoaDon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        fetchTodayBill()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    deinit {
        logger()
    }
    
    private func setupViews() {
        
        billTableView.dataSource = self
        billTableView.delegate = self
        
        billTableView.register(UINib(nibName: tableViewProperties.rowNibName, bundle: nil), forCellReuseIdentifier: tableViewProperties.rowID)
    }
    
    func fetchTodayBill() {
        HoaDon.fetchTodayPaidBill { [weak self] hoadons, error in
            if let hoadons = hoadons {
                self?.bills = hoadons
            }
            self?.bills.sort{ $0.ngaytao.timeIntervalSince1970 > $1.ngaytao.timeIntervalSince1970}
            self?.billTableView.reloadData()
        }
    }

    @IBAction func btnBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

}

extension BillHistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableViewProperties.rowID, for: indexPath) as? BillTableViewCell else {
            fatalError("BillTableViewCell: Can't dequeue for BillTableViewCell")
        }
        cell.bill = bills[indexPath.item]
        return cell
    }
    
    
}

extension BillHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewProperties.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let presenter = PresentHandler()
        presenter.presentBillManagerVC(self, bill: bills[indexPath.item], forBillHistory: true)
    }
}
