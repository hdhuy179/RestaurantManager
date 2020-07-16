
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
    @IBOutlet weak var btn8: RaisedButton!
    
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var img5: UIImageView!
    @IBOutlet weak var img6: UIImageView!
    @IBOutlet weak var img7: UIImageView!
    @IBOutlet weak var img8: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btn1.pulseColor = .white
        img1.tintColor = Color.blue.base
        btn2.pulseColor = .white
        img2.tintColor = Color.blue.base
        btn3.pulseColor = .white
        img3.tintColor = Color.blue.base
        btn4.pulseColor = .white
        img4.tintColor = Color.blue.base
        btn5.pulseColor = .white
        img5.tintColor = Color.blue.base
        btn6.pulseColor = .white
        img6.tintColor = Color.blue.base
        btn7.pulseColor = .white
        img7.tintColor = Color.blue.base
        btn8.pulseColor = .white
        img8.tintColor = Color.blue.base
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
    
    @IBAction func btnReportManagerWasTapped(_ sender: Any) {
        
    }
    
    func presentManagerDataVC(for type: ManageType) {
        let presentHandler = PresentHandler()
        presentHandler.presentManagerDataVC(self, manageType: type)
    }
}
