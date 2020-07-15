
//
//  ManagerFeatureMenuViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/31/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class ManagerFeatureMenuViewController: UIViewController {
    
    @IBOutlet weak var btn1: RaisedButton!
    @IBOutlet weak var btn2: RaisedButton!
    @IBOutlet weak var btn3: RaisedButton!
    @IBOutlet weak var btn4: RaisedButton!
    @IBOutlet weak var btn5: RaisedButton!
    @IBOutlet weak var btn6: RaisedButton!
    @IBOutlet weak var btn7: RaisedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btn1.pulseColor = .white
        btn1.backgroundColor = Color.blue.base
        btn2.pulseColor = .white
        btn2.backgroundColor = Color.blue.base
        btn3.pulseColor = .white
        btn3.backgroundColor = Color.blue.base
        btn4.pulseColor = .white
        btn4.backgroundColor = Color.blue.base
        btn5.pulseColor = .white
        btn5.backgroundColor = Color.blue.base
        btn6.pulseColor = .white
        btn6.backgroundColor = Color.blue.base
        btn7.pulseColor = .white
        btn7.backgroundColor = Color.blue.base
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnTableManagerWasTapped(_ sender: Any) {
        presentManagerDataVC(for: .table)
    }
    
    @IBAction func btnBillManagerWasTapped(_ sender: Any) {
        presentManagerDataVC(for: .bill)
    }
    
    @IBAction func btnStaffManagerWasTapped(_ sender: Any) {
        presentManagerDataVC(for: .staff)
    }
    
    @IBAction func btnDishCategoryManagerWasTapped(_ sender: Any) {
        presentManagerDataVC(for: .dishCategory)
    }
    
    @IBAction func btnDishManagerWasTapped(_ sender: Any) {
        presentManagerDataVC(for: .dish)
    }
    
    @IBAction func btnImportBillManagerWasTapped(_ sender: Any) {
        presentManagerDataVC(for: .importBill)
    }
    
    @IBAction func btnExportBillManagerWasTapped(_ sender: Any) {
        presentManagerDataVC(for: .exportBill)
    }
    
    func presentManagerDataVC(for type: ManageType) {
        let presentHandler = PresentHandler()
        presentHandler.presentManagerDataVC(self, manageType: type)
    }
}
