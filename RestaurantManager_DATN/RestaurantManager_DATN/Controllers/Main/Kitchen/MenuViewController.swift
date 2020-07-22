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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topConstantTableView: NSLayoutConstraint!
    
    private struct tableViewProperties {
        static let headerNibName = "DishHeaderTableViewCell"
        static let headerID = "DishHeaderTableViewCell"
        static let headerHeight: CGFloat = 50.0
        
        static let rowNibName = "MenuDishTableViewCell"
        static let rowID = "MenuDishTableViewCell"
        static let rowHeight: CGFloat = 100.0
    }
    
    var dishData: [[MonAn]] = []
    var currentDishData: [[MonAn]] = []
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
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        
        dishTableView.dataSource = self
        dishTableView.delegate = self
        
        dishTableView.register(UINib(nibName: tableViewProperties.headerNibName, bundle: nil), forCellReuseIdentifier: tableViewProperties.headerID)
        dishTableView.register(UINib(nibName: tableViewProperties.rowNibName, bundle: nil), forCellReuseIdentifier: tableViewProperties.rowID)
    }
    
    func fetchData() {
        MonAn.fetchAllDataAvailable { [weak self](data, error) in
            if error != nil {
                
            } else if let data = data {
                
                self?.dishData = [data]
                if !(self?.dishCategoryData.isEmpty ?? true) {
                    self?.setupData()
                }
            }
        }
        TheLoaiMonAn.fetchAllDataAvailable{ [weak self](data, error) in
            if error != nil {
                
            } else if let data = data {
                self?.dishCategoryData = data
                if !(self?.currentDishData.isEmpty ?? true) {
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
        currentDishData = dishData
        dishTableView.reloadData()
    }
    @IBAction func btnSearchTapped(_ sender: Any) {
        searchBar.becomeFirstResponder()
        topConstantTableView.constant = 53
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
        return currentDishData[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentDishData[section].isEmpty == true {
            return nil
        }
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
        cell.configView(data: currentDishData[indexPath.section][indexPath.item])
        cell.delegate = self
        return cell
    }
    
    
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewProperties.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentDishData[section].isEmpty == true {
            return 0
        }
        return tableViewProperties.headerHeight
    }
}

extension MenuViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        topConstantTableView.constant = 0
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == true {
            currentDishData = dishData
            dishTableView.reloadData()
            return
        }
        let searchText = searchText.lowercased()
        let dishCategoryList = dishCategoryData.filter({ $0.tentheloaimonan.lowercased().contains(searchText)})
        currentDishData.removeAll()
        for list in dishData {
            let result = list.filter({
                let currentItem = $0
                return ($0.tenmonan.lowercased().contains(searchText) || dishCategoryList.filter({ $0.idtheloaimonan == currentItem.idtheloaimonan }).isEmpty == false) })
            currentDishData.append(result)
        }
        
        dishTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
