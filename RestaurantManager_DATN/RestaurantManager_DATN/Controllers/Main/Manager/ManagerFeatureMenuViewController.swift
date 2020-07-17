
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

        
        
//        img1.tintColor = Color.blue.base
//        img2.tintColor = Color.blue.base
//        img3.tintColor = Color.blue.base
//        img4.tintColor = Color.blue.base
//        img5.tintColor = Color.blue.base
//        img6.tintColor = Color.blue.base
//        img7.tintColor = Color.blue.base
//        img8.tintColor = Color.blue.base
//        
        btn1.pulseColor = .white
        btn2.pulseColor = .white
        btn3.pulseColor = .white
        btn4.pulseColor = .white
        btn5.pulseColor = .white
        btn6.pulseColor = .white
        btn7.pulseColor = .white
        btn8.pulseColor = .white
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
    
//    @IBAction func btnReportManagerWasTapped(_ sender: Any) {
//
//    }
    
    func presentManagerDataVC(for type: ManageType) {
        let presentHandler = PresentHandler()
        presentHandler.presentManagerDataVC(self, manageType: type)
    }
}
