//
//  ReportMenuFeatureViewController.swift
//  RestaurantManager_DATN
//
//  Created by HuyHoangDinh on 7/17/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class ReportMenuFeatureViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnReportHistoryWasTapped(_ sender: Any) {
        presentManagerDataVC(for: .report)
    }
    
    @IBAction func btnReportType1WasTapped(_ sender: Any) {
        presentCreateReportVC(for: .income)
    }
    
    @IBAction func btnReportType2WasTapped(_ sender: Any) {
        presentCreateReportVC(for: .bestSeller)
    }
    
    @IBAction func btnReportType3WasTapped(_ sender: Any) {
        presentCreateReportVC(for: .stuffUsed)
    }
    
    func presentCreateReportVC(for type: ReportType) {
        let presentHandler = PresentHandler()
        presentHandler.presentCreateReportVC(self, type: type)
    }
    
    func presentManagerDataVC(for type: ManageType) {
        let presentHandler = PresentHandler()
        presentHandler.presentManagerDataVC(self, manageType: type)
    }

}
