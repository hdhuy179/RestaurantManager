//
//  MenuViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 2/1/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

final class FeatureMenuViewController: UIViewController {

    @IBOutlet weak var genaralView: UIView!
    
    @IBOutlet weak var staffAvatarImageView: UIView!
    @IBOutlet weak var staffNameLabel: UILabel!
    @IBOutlet weak var staffPositionLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchData()
    }
    
    func fetchData() {
        if let data = App.shared.staffInfo {
            staffNameLabel.text = data.tennhanvien
            staffPositionLabel.text = data.getPosition()
        }
    }
    
    private func setupView() {
        genaralView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.genaralView.alpha = 1
        }
    }
    
    @IBAction func btnStaffInfoTapped(_ sender: Any) {
        let present = PresentHandler()
        if let staff = App.shared.staffInfo {
            present.presentStaffManagerVC(self, staff: staff, forStaffDetail: true)
        }
        
    }
    
    @IBAction func btnCallManagerTapped(_ sender: Any) {
        self.showAlert(title: "Thông báo", message: "Chức năng đang được xây dựng. Vui lòng thử lại sau.")
    }
    
    @IBAction func btnSupportTapped(_ sender: Any) {
        self.showAlert(title: "Mọi yêu cầu hỗ trợ", message: "Xin vui lòng liên hệ: Hoàng Đình Huy\n SĐT: 0339519315\nEmail: vn01639519315@gmail.com")
    }
    
    @IBAction func btnPrinterSettingTapped(_ sender: Any) {
        self.showAlert(title: "Thông báo", message: "Chức năng đang được xây dựng. Vui lòng thử lại sau.")
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        self.showConfirmAlert(title: "Đăng xuất", message: "Bạn có chắc muốn đăng xuất khỏi ứng dụng không?") {
            App.shared.transitionToLoginView()
        }
        
    }
    

}
