//
//  PresentHandler.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/31/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import Foundation

class PresentHandler {
    
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func presentManagerDataVC(_ rootVC: UIViewController, manageType: ManageType, isForPickData: Bool = false) {
        let vc = storyboard.instantiateViewController(withIdentifier: "ManagerDataViewController") as! ManagerDataViewController
        
        vc.managerType = manageType
        vc.isForPickData = isForPickData
        
        if let rootVC = rootVC as? ManagerPickedData {
            vc.delegate = rootVC
        }
        
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentTableBillDetailVC(_ rootVC: UIViewController, table: BanAn? = nil) {
        let vc = storyboard.instantiateViewController(withIdentifier: "TableBillDetailViewController") as! TableBillDetailViewController
        vc.table = table
        if let rootVC = rootVC as? RestaurantViewController {
            vc.delegate = rootVC
        }
        
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentBillHistoryVC(_ rootVC: UIViewController, table: BanAn? = nil) {
        let vc = storyboard.instantiateViewController(withIdentifier: "BillHistoryViewController") as! BillHistoryViewController
        
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentMakeOrderVC(_ rootVC: UIViewController, tableData: BanAn? = nil) {
        let vc = storyboard.instantiateViewController(withIdentifier: "MakeOrderViewController") as! MakeOrderViewController
        vc.table = tableData
        if let rootVC = rootVC as? RestaurantViewController {
            vc.delegate = rootVC
        }
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentMenuVC(_ rootVC: UIViewController) {
        let vc = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentDishManagerVC(_ rootVC: UIViewController, dishData: MonAn? = nil) {
        let vc = storyboard.instantiateViewController(withIdentifier: "DishManagerViewController") as! DishManagerViewController
        vc.dish = dishData
        if let rootVC = rootVC as? ManagerDataViewController {
            vc.delegate = rootVC
        }
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentDishCategoryManagerVC(_ rootVC: UIViewController, dishCategoryData: TheLoaiMonAn? = nil) {
        let vc = storyboard.instantiateViewController(withIdentifier: "DishCategoryManagerViewController") as! DishCategoryManagerViewController
        vc.dishCategory = dishCategoryData
        if let rootVC = rootVC as? ManagerDataViewController {
            vc.delegate = rootVC
        }
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentTableManagerVC(_ rootVC: UIViewController, table: BanAn? = nil) {
        let vc = storyboard.instantiateViewController(withIdentifier: "TableManagerViewController") as! TableManagerViewController
        vc.table = table
        if let rootVC = rootVC as? ManagerDataViewController {
            vc.delegate = rootVC
        }
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentBillManagerVC(_ rootVC: UIViewController, bill: HoaDon? = nil, forBillHistory: Bool = false) {
        let vc = storyboard.instantiateViewController(withIdentifier: "BillManagerViewController") as! BillManagerViewController
        vc.bill = bill
        if let rootVC = rootVC as? ManagerDataViewController {
            vc.delegate = rootVC
        }
        vc.forBillHistory = forBillHistory
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentStaffManagerVC(_ rootVC: UIViewController, staff: NhanVien? = nil) {
        let vc = storyboard.instantiateViewController(withIdentifier: "StaffManagerViewController") as! StaffManagerViewController
        vc.staff = staff
        if let rootVC = rootVC as? ManagerDataViewController {
            vc.delegate = rootVC
        }
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentAddStaffManagerVC(_ rootVC: UIViewController) {
        let vc = storyboard.instantiateViewController(withIdentifier: "AddStaffManagerViewController") as! AddStaffManagerViewController
        
        if let rootVC = rootVC as? ManagerDataViewController {
            vc.delegate = rootVC
        }
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentSearchBillManagerVC(_ rootVC: UIViewController, bills: [[HoaDon]]) {
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchBillMangerViewController") as! SearchBillMangerViewController
        
        vc.billData = bills
        rootVC.presentInFullScreen(vc, animated: false)
    }
    
    func presentImportBillManagerVC(_ rootVC: UIViewController, data: PhieuNhap? = nil, forDetail: Bool = false, forStorager: Bool = false) {
        let vc = storyboard.instantiateViewController(withIdentifier: "ImportBillManagerViewController") as! ImportBillManagerViewController
        
        vc.importBill = data
        vc.forDetail = forDetail
        vc.forStorager = forStorager
        if let rootVC = rootVC as? ManagerDataViewController {
            vc.delegate = rootVC
        }
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentExportBillManagerVC(_ rootVC: UIViewController, data: PhieuXuat? = nil, imp: PhieuNhap? = nil, forShowDetails: Bool = false) {
        let vc = storyboard.instantiateViewController(withIdentifier: "ExportBillManagerViewController") as! ExportBillManagerViewController
        
        vc.exportBill = data
        vc.importBill = imp
        
        vc.forShowDetails = forShowDetails
        
        if let rootVC = rootVC as? ManagerDataViewController {
            vc.delegate = rootVC
        }
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentCreateReportVC(_ rootVC: UIViewController, type: ReportType) {
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateReportManagerViewController") as! CreateReportManagerViewController
        vc.reportType = type
        if let rootVC = rootVC as? ManagerDataViewController {
            vc.delegate = rootVC
        }
        rootVC.presentInFullScreen(vc, animated: true)
    }
    
    func presentReportDetailsVC(_ rootVC: UIViewController, data: BaoCao) {
        let vc = storyboard.instantiateViewController(withIdentifier: "ReportDetailsManagerViewController") as! ReportDetailsManagerViewController
        vc.report = data
        if let rootVC = rootVC as? ManagerDataViewController {
            vc.delegate = rootVC
        }
        rootVC.presentInFullScreen(vc, animated: true)
    }
}
