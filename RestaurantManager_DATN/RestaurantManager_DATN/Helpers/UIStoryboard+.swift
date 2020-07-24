//
//  UIStoryboard+.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 1/30/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}

extension UIStoryboard {
    
    var LoginNavigationViewController: LoginNavigationViewController {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "LoginNavigationViewController") as? LoginNavigationViewController else {
            fatalError("LoginNavigationViewController couldn't be found in Storyboard file")
        }
        return vc
    }
    
    var MainNavigationViewController: MainNavigationViewController {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "MainNavigationViewController") as? MainNavigationViewController else {
            fatalError("MainNavigationViewController couldn't be found in Storyboard file")
        }
        return vc
    }
    
    var LogoViewController: UIViewController {
        let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "LogoViewController")
        return vc
    }
    
//    var LoginViewController: LoginViewController {
//        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
//            fatalError("LoginViewController couldn't be found in Storyboard file")
//        }
//        return vc
//    }
//
//    var TableViewController: TableViewController {
//        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "TableViewController") as? TableViewController else {
//            fatalError("TableViewController couldn't be found in Storyboard file")
//        }
//        return vc
//    }
}

