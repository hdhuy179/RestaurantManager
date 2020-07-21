//
//  UiViewController+.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 1/30/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

extension UIViewController {
    func logger() {
        print(String(describing: type(of: self)) + " deinited")
    }
    
}

extension UIViewController {
    func presentInFullScreen(_ viewController: UIViewController,
                             animated: Bool,
                             completion: (() -> Void)? = nil) {
      viewController.modalPresentationStyle = .fullScreen
      present(viewController, animated: animated, completion: completion)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okeAction = UIAlertAction(title: "Xác nhận", style: .cancel) { _ in
            completion?()
        }
        alert.addAction(okeAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showConfirmAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okeAction = UIAlertAction(title: "Xác nhận", style: .cancel) { _ in
            completion?()
        }
        let cancelAction = UIAlertAction(title: "Huỷ", style: .default) { _ in
            
        }
        alert.addAction(okeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension UIViewController {
    var endEditingTapGesture: UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(endEditingTapGestureHandler))
    }

    @objc
    private func endEditingTapGestureHandler() {
        view.endEditing(true)
    }
}

var tapGesture: UITapGestureRecognizer!
extension UIViewController {
    func addEndEditingTapGuesture() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.removeGestureRecognizer(tapGesture)
    }
}
