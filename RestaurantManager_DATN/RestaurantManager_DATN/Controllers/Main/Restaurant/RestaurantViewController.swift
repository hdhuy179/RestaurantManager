//
//  TableViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 2/5/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class RestaurantViewController: UIViewController {

    @IBOutlet weak var tableCollectionView: UICollectionView!
    
    private lazy var tableRefreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        return refresh
    } ()
    
    private var tableSearchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Tìm Bàn..."
        searchController.hidesNavigationBarDuringPresentation = true
//        searchController.searchResultsUpdater = self
        return searchController
    } ()
    
    private struct collectionViewProperties {
        static let cellNibName = "TableCollectionViewCell"
        static let cellID = "TableCellID"
        static let cellHeight: CGFloat = 250.0
        static let numberOfCellsForRow: CGFloat = 3.0
    }
    
    var tableData: [BanAn] = []
    var currentTableData: [BanAn] = []
    
    var currentBillData: [HoaDon] = []
    
    deinit {
        logger()
    }
    
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
        
        tableCollectionView.refreshControl = tableRefreshControl
        tableCollectionView.dataSource = self
        tableCollectionView.delegate = self
        
        tableCollectionView.register(UINib(nibName: collectionViewProperties.cellNibName, bundle: nil), forCellWithReuseIdentifier: collectionViewProperties.cellID)
    }
    
    @objc func fetchData() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        var isTableLoaded = false
        var isBillLoaded = false
        
        BanAn.fetchAllDataAvailable { [weak self] (data, error) in
            if error != nil {
                print(error.debugDescription)
            } else if let data = data {
                self?.tableData = data
            }
            isTableLoaded = true
            if isBillLoaded {
                self?.setupData()
            }
            
        }
        
        HoaDon.fetchUnpaidBill { [weak self] (data, error) in
            if error != nil {
                print(error.debugDescription)
            } else if let data = data {
                self?.currentBillData = data
            }
            isBillLoaded = true
            if isTableLoaded {
                self?.setupData()
            }
        }
        
//        self.navigationController?.navigationBar.prefersLargeTitles = false
        
//        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
//            self.tableRefreshControl.endRefreshing()
//            self.navigationController?.navigationBar.prefersLargeTitles = true
//        }
    }
    
    func setupData() {
//        userProfileNameLabel.text = "\(String(restaurantStaff.first_name)) \(String(restaurantStaff.last_name))"
        tableRefreshControl.endRefreshing()
        
        for (index, table)in tableData.enumerated() {
            for bill in currentBillData {
                if bill.idbanan == table.idbanan {
                    tableData[index].bill = bill
                }
            }
        }
        currentTableData = tableData
        self.tableCollectionView.reloadData()
//        self.hideActivityIndicatorView()
    }
    
    @IBAction func billHistoryButtonTapped(_ sender: Any) {
//        self.performSegue(withIdentifier: segueProperties.toTakeawayVCSegue.rawValue, sender: self)
        let presenter = PresentHandler()
        presenter.presentBillHistoryVC(self)
    }
    

}

extension RestaurantViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentTableData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewProperties.cellID, for: indexPath) as? TableCollectionViewCell else {
            fatalError("RestaurantViewController: Can't deque for tableCollectionViewCell")
        }
        if let bill = currentTableData[indexPath.item].bill, let served = bill.isBillServed(){
            if served {
                cell.state = .inUsed
            } else {
                cell.state = .waiting
            }
        } else {
            cell.state = .empty
        }
        cell.configView(data: currentTableData[indexPath.item])
        return cell
    }
    
    
}

extension RestaurantViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let minimumInteritemSpacing = layout?.minimumInteritemSpacing ?? 0.0
        let leftAndRightSectionInset = (layout?.sectionInset.left ?? 0) + (layout?.sectionInset.right ?? 0)
        
        
        let tableCellWidth = ((collectionView.frame.size.width - leftAndRightSectionInset - minimumInteritemSpacing * (collectionViewProperties.numberOfCellsForRow - 1.0))/collectionViewProperties.numberOfCellsForRow).rounded(.towardZero)
        return CGSize(width: tableCellWidth, height: UIScreen.main.bounds.height/6)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let presentHandler = PresentHandler()
        guard let cell = collectionView.cellForItem(at: indexPath) as? TableCollectionViewCell else { return }
        if cell.state == .empty {
            presentHandler.presentMakeOrderVC(self, tableData: currentTableData[indexPath.item])
        } else {
            presentHandler.presentTableBillDetailVC(self, table: currentTableData[indexPath.item])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let yTranslation = scrollView.panGestureRecognizer.translation(in: scrollView).y
//        if yTranslation >= 50 {
//            navigationController?.setNavigationBarHidden(false, animated: true)
//        } else if yTranslation <= -50 {
//            navigationController?.setNavigationBarHidden(true, animated: true)
//        }
    }
}

extension RestaurantViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard var text = searchController.searchBar.text else { return }
        
        text = text.lowercased()
        if let _ = text.lowercased().range(of: "bàn") {
            text = text.replacingOccurrences(of: "bàn", with: "")
        } else if let  _ = text.lowercased().range(of: "ban") {
            text = text.replacingOccurrences(of: "ban", with: "")
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty == false {
            currentTableData = tableData.filter { $0.sobanan?.range(of: text) != nil}
        } else {
            currentTableData = tableData
        }
        tableCollectionView.reloadData()
    }
}
