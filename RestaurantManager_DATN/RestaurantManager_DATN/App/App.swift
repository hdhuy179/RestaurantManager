//
//  App.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 1/30/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit
import FirebaseAuth

final class App: UINavigationController {
    static let shared = App()
    
    var window: UIWindow!
    var staffInfo: NhanVien?
    
    func startInterface() {
        if Auth.auth().currentUser != nil {
            let vc = UIStoryboard.main.LogoViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = true
            
            UIView.transition(with: window, duration: 0, animations: {
                self.window.rootViewController = nav
            }, completion: nil)
            transitionToTableView()
        } else {
            transitionToLoginView()
        }
        
        window.makeKeyAndVisible()
    }
    
    func transitionToLoginView() {
        let vc = UIStoryboard.main.LoginNavigationViewController
        do {
            try Auth.auth().signOut()
            changeView(vc)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func transitionToTableView(fromVC: UIViewController? = nil) {
        if let currentUser = Auth.auth().currentUser {
            NhanVien.fetchData(forAccountID: currentUser.uid) { [weak self] data, error in
                if let data = data {
                    if data.quyen < 0 || data.quyen > 5 {
                        self?.transitionToLoginView()
                    }
                    self?.staffInfo = data
                    let vc = UIStoryboard.main.MainNavigationViewController
                    self?.changeView(vc)
                } else if error == nil {
                    fromVC?.showAlert(title: "Thông báo", message: "Tài khoản của bạn đã bị xoá hoặc không tồn tai trong hệ thống.")
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                    if !(fromVC is LoginViewController) {
                        self?.transitionToLoginView()
                    }
                    
                } else {
                    fromVC?.showAlert(title: "Lỗi đang nhập", message: error.debugDescription)
                }
            }
        }
    }
    
     func changeView(_ rootViewController: UINavigationController) {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.window.rootViewController = rootViewController
            }, completion: nil)
        }
}
