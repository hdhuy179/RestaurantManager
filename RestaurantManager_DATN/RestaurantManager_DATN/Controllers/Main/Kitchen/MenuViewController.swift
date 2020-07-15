//
//  MenuViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 2/8/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var dishTableView: UITableView!
    
    private struct tableViewProperties {
        static let headerNibName = "DishHeaderTableViewCell"
        static let headerID = "DishHeaderTableViewCell"
        static let headerHeight: CGFloat = 50.0
        
        static let rowNibName = "MenuDishTableViewCell"
        static let rowID = "MenuDishTableViewCell"
        static let rowHeight: CGFloat = 100.0
    }
    
    var dishData: [[MonAn]] = []
    var dishCategoryData: [TheLoaiMonAn] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupViews()
        fetchData()
    }
    
    deinit {
        logger()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let present = presentingViewController as? TableBillDetailViewController {
            present.fetchBillData()
        }
    }
    
    private func setupViews() {
        dishTableView.dataSource = self
        dishTableView.delegate = self
        
        dishTableView.register(UINib(nibName: tableViewProperties.headerNibName, bundle: nil), forCellReuseIdentifier: tableViewProperties.headerID)
        dishTableView.register(UINib(nibName: tableViewProperties.rowNibName, bundle: nil), forCellReuseIdentifier: tableViewProperties.rowID)
    }
    
    func fetchData() {
        MonAn.fetchAllDataAvailable { [weak self](data, error) in
            if error != nil {
                
            } else if let data = data {
                
                self?.dishData.append(data)
                if !(self?.dishCategoryData.isEmpty ?? true) {
                    self?.setupData()
                }
            }
        }
        TheLoaiMonAn.fetchAllDataAvailable{ [weak self](data, error) in
            if error != nil {
                
            } else if let data = data {
                self?.dishCategoryData = data
                if !(self?.dishData.isEmpty ?? true) {
                    self?.setupData()
                }
            }
        }
    }
    
    func setupData() {
        if !self.dishData.isEmpty, !self.dishCategoryData.isEmpty {
            let dishDataEmp = self.dishData[0]
            dishData.removeAll()
            for (index, dishCategory) in dishCategoryData.enumerated() {
                dishData.append([])
                for dish in dishDataEmp {
                    if dish.idtheloaimonan == dishCategory.idtheloaimonan {
                        dishData[index].append(dish)
                    }
                }
            }
        }
        dishTableView.reloadData()
    }

    @IBAction func btnBackWasTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension MenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dishCategoryData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishData[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: tableViewProperties.headerID) as? DishHeaderViewCell else {
            fatalError("MenuViewController: Can't dequeue for DishHeaderViewCell")
        }
        headerCell.dishCategoryLabel.text = dishCategoryData[section].tentheloaimonan
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableViewProperties.rowID, for: indexPath) as? MenuDishTableViewCell else {
            fatalError("MenuViewController: Can't dequeue for DishTableViewCell")
        }
        cell.configView(data: dishData[indexPath.section][indexPath.item])
        return cell
    }
    
    
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewProperties.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewProperties.headerHeight
    }
}
