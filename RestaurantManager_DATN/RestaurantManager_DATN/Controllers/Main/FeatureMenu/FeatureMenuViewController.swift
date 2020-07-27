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
    
    var visualEffectView: UIVisualEffectView?
    var callManagerView: CallManagerView?
    
    var managerData: [NhanVien] = []
    
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
        
        NhanVien.fetchAllManagerData { [weak self](datas, err) in
            if let datas = datas {
                self?.managerData = datas
            }
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
//        self.showAlert(title: "Thông báo", message: "Chức năng đang được xây dựng. Vui lòng thử lại sau.")
//        if let phoneCallURL = URL(string: "telprompt://\()") {
//
//            let application:UIApplication = UIApplication.shared
//            if (application.canOpenURL(phoneCallURL)) {
//                if #available(iOS 10.0, *) {
//                    application.open(phoneCallURL, options: [:], completionHandler: nil)
//                } else {
//                    // Fallback on earlier versions
//                     application.openURL(phoneCallURL as URL)
//
//                }
//            }
//        }
        let nib = UINib(nibName: "CallManagerView", bundle: nil)
        if let callManagerView = nib.instantiate(withOwner: self, options: nil).first as? CallManagerView {
            visualEffectView = UIVisualEffectView()
            visualEffectView?.frame = self.view.frame
            visualEffectView?.effect = UIBlurEffect(style: .dark)
            self.view.addSubview(visualEffectView!)
            
            self.callManagerView = callManagerView
            
            let width: CGFloat = UIScreen.main.bounds.width - 70
            let height: CGFloat = UIScreen.main.bounds.height*0.60
            callManagerView.frame = CGRect(x: (UIScreen.main.bounds.width - width)/2, y: UIScreen.main.bounds.height, width: width, height: height)
            callManagerView.delegate = self
            callManagerView.configView(datas: managerData)
            self.view.addSubview(callManagerView)
            
            UIView.animate(withDuration: 0.25) {
//                callManagerView.frame.origin.x = (UIScreen.main.bounds.width - width)/2
                callManagerView.frame.origin.y = (UIScreen.main.bounds.height - height)/2
            }
        }
    }
    
    func btnCancelTappedInCallManagerView() {

        UIView.animate(withDuration: 0.25, animations: {
//            self.callManagerView?.frame.origin.x = UIScreen.main.bounds.width
            self.callManagerView?.frame.origin.y = UIScreen.main.bounds.height
        }) { (_) in
            self.visualEffectView?.removeFromSuperview()
            self.callManagerView?.removeFromSuperview()
        }
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
