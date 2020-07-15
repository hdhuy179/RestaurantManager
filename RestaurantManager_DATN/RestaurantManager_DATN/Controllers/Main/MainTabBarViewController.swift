//
//  MainViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 2/8/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    enum ItemsValue : Int {
        case Restaurant = 0, Kitchen, Storage, Manager, FeatureMenu
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.tabBar.items?[ItemsValue.Manager.rawValue].isEnabled = false
        
    }
    

}
