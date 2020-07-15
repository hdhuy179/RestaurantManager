//
//  SearchBillMangerViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 7/7/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class SearchBillMangerViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnAddNewData: UIButton!
    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet weak var swShowDeletedData: UISegmentedControl!
    @IBOutlet weak var txtStartDate: TextField!
    @IBOutlet weak var txtEndDate: TextField!
    @IBOutlet weak var vSearch: UIView!
    @IBOutlet weak var btnSearch: RaisedButton!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    
    var billData: [[HoaDon]] = []
    
    private var currentBillData: [[HoaDon]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
        setupData(withList: billData)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    private func setupView() {
        
        addEndEditingTapGuesture()
        txtStartDate.isDatePickerTextField(dateFormat: "dd/MM/yyyy")
        txtEndDate.isDatePickerTextField(maximumDate: Date(), dateFormat: "dd/MM/yyyy")
        txtStartDate.isClearIconButtonEnabled = true
        txtEndDate.isClearIconButtonEnabled = true
        
        btnSearch.pulseColor = .white
        
        dataTableView.delegate = self
        dataTableView.dataSource = self
        
        dataTableView.register(UINib(nibName: "BillTableViewCell", bundle: nil), forCellReuseIdentifier: "BillTableViewCell")
        
    }
    
    private func setupData(withList: [[HoaDon]]) {
        self.currentBillData.removeAll()
        for item in withList {
            if swShowDeletedData.selectedSegmentIndex == 0 {
                currentBillData.append( item.filter { $0.daxoa == 0 })
            } else {
                currentBillData.append( item.filter { $0.daxoa == 1 })
            }
        }
        dataTableView.reloadData()
    }
    
    @IBAction func swChanged(_ sender: Any) {
//        setupData(withList: billData)
    }
    
    @IBAction func startDateTextFieldEditingDidEnd(_ sender: Any) {
        txtEndDate.isDatePickerTextField(minimumDate: Date.getDate(fromString: txtStartDate.text!, withDateFormat: "dd/MM/yyyy"), maximumDate: Date(), dateFormat: "dd/MM/yyyy")
        if txtStartDate.text?.isEmpty == true {
            setupData(withList: billData)
        }
//        checkSearchBillEnable()
    }
    
    @IBAction func endDateTextFieldEditingDidEnd(_ sender: Any) {
        txtStartDate.isDatePickerTextField(maximumDate: Date.getDate(fromString: txtEndDate.text!, withDateFormat: "dd/MM/yyyy"))
        if txtEndDate.text?.isEmpty == true {
            setupData(withList: billData)
        }
//        checkSearchBillEnable()
    }
    
    func checkSearchBillEnable() {
        if Date.getDate(fromString: txtStartDate.text!, withDateFormat: "dd/MM/yyyy") != nil &&
        Date.getDate(fromString: txtEndDate.text!, withDateFormat: "dd/MM/yyyy") != nil &&
        Date.getDate(fromString: txtStartDate.text!, withDateFormat: "dd/MM/yyyy")!.timeIntervalSince1970 <= Date.getDate(fromString: txtEndDate.text!, withDateFormat: "dd/MM/yyyy")!.timeIntervalSince1970 {
            btnSearch.isEnabled = true
            btnSearch.backgroundColor = .systemGreen
        } else {
            btnSearch.isEnabled = false
            btnSearch.backgroundColor = .systemGray
        }
    }
    
    @IBAction func btnSearchTapped(_ sender: Any) {
        
        if txtStartDate.text?.isEmpty == true {
            txtStartDate.text = txtEndDate.text
        } else if txtEndDate.text?.isEmpty == true {
            txtEndDate.text = txtStartDate.text
        }
        
        var temp : [[HoaDon]] = []
        guard let start = Date.getDate(fromString: txtStartDate.text ?? "", withDateFormat: "dd/MM/yyyy"),
            let end = Date.getDate(fromString: txtEndDate.text ?? "", withDateFormat: "dd/MM/yyyy") else { return }
        let arr = start...end
        
        for list in billData {
            if let first = list.first {
                if arr.contains(first.ngaytao) {
                    temp.append(list)
                }
            }
        }
        currentBillData.removeAll()
        setupData(withList: temp)
    }
    
    @IBAction func btnBackWasTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension SearchBillMangerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentBillData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentBillData[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(currentBillData[section].first?.ngaytao.convertToString().dropLast(9) ?? "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillTableViewCell", for: indexPath) as? BillTableViewCell else { fatalError("") }
        cell.bill = currentBillData[indexPath.section][indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SearchBillMangerViewController: UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let presentHandler = PresentHandler()
        presentHandler.presentBillManagerVC(self, bill: currentBillData[indexPath.section][indexPath.item])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yTranslation = scrollView.panGestureRecognizer.translation(in: scrollView).y
        if yTranslation >= 50 {
            heightConstant.constant = 100
            vSearch.isHidden = false
        } else if yTranslation <= -50 {
            vSearch.isHidden = true
            heightConstant.constant = 0
        }
    }
}

