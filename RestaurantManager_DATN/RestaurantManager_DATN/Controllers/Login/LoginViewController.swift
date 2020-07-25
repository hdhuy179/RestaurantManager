//
//  ViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 1/29/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var btnLogin: RaisedButton!
    @IBOutlet weak var btnResetPassword: RaisedButton!
    @IBOutlet weak var showErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupViews()
        
        usernameTextField.delegate = self
        usernameTextField.isClearIconButtonEnabled = true
        usernameTextField.clearButtonMode = .whileEditing
        
        passwordTextField.delegate = self
        passwordTextField.isVisibilityIconButtonEnabled = true
        
        btnLogin.layer.cornerRadius = 5
        btnLogin.pulseColor = .white
        btnLogin.backgroundColor = Color.blue.base
        
    }
    
    deinit {
        logger()
    }

    private func setupViews() {
        showErrorLabel.alpha = 0
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        btnLogin.isEnabled = false
        Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (result, error) in
            self.btnLogin.isEnabled = true
            if error != nil {
                self.showErrorLabel.alpha = 1
                self.showErrorLabel.text = error?.localizedDescription
            } else {
                App.shared.transitionToTableView(fromVC: self)
            }
            
        }
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        btnResetPassword.isEnabled = false
        let alert = UIAlertController(title: "Quên mật khẩu" , message: "Nhập địa chỉ email của bạn:", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .emailAddress
        }
        alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: { (action) in
            guard let text = alert.textFields?.first?.text else { return }
            Auth.auth().sendPasswordReset(withEmail: text) { [weak self](error) in
                if error == nil {
                    self?.showAlert(title: "Đổi mật khẩu", message: "Vui lòng truy cập đến hòm thư \"\(text)\" để tạo mật khẩu mới.")
                } else {
                    self?.showErrorLabel.text = "\(error?.localizedDescription ?? "")"
                    self?.showErrorLabel.alpha = 1
                }
                self?.btnResetPassword.isEnabled = true
            }
        }))
        self.present(alert, animated: true)

    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addGestureRecognizer(endEditingTapGesture)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.removeGestureRecognizer(endEditingTapGesture)
    }

}
