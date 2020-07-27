//
//  CallManagerView.swift
//  RestaurantManager_DATN
//
//  Created by HuyHoangDinh on 7/27/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class CallManagerView: UIView {
    @IBOutlet weak var tbvPhone: UITableView!
    weak var delegate: FeatureMenuViewController?
    
    var managerData: [NhanVien] = []
    
    func configView(datas: [NhanVien]) {
        self.layer.cornerRadius = 12
        
        tbvPhone.delegate = self
        tbvPhone.dataSource = self
        
        tbvPhone.register(UINib(nibName: "ManagerCallTableViewCell", bundle: nil), forCellReuseIdentifier: "ManagerCallTableViewCell")
        
        managerData = datas
        tbvPhone.reloadData()
    }
    
    @IBAction func btnCancelTapped(_ sender: Any) {
        delegate?.btnCancelTappedInCallManagerView()
    }
}

extension CallManagerView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return managerData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ManagerCallTableViewCell", for: indexPath) as? ManagerCallTableViewCell else { fatalError("") }
        cell.configView(data: managerData[indexPath.item])
        return cell
    }
    
    
}

extension CallManagerView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let phoneCallURL = URL(string: "telprompt://\(managerData[indexPath.item].sodienthoai)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    application.openURL(phoneCallURL as URL)
                    
                }
            }
        }
    }
}
