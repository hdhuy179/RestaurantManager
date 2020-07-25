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
        if App.shared.staffInfo?.quyen != 1 {
            self.tabBar.items?[ItemsValue.Manager.rawValue].isEnabled = false
        }
        
        if App.shared.staffInfo?.quyen == 2 || App.shared.staffInfo?.quyen == 3 {
            self.tabBar.items?[ItemsValue.Storage.rawValue].isEnabled = false
        }
        
        if App.shared.staffInfo?.quyen == 5 {
            self.tabBar.items?[ItemsValue.Restaurant.rawValue].isEnabled = false
            self.tabBar.items?[ItemsValue.Kitchen.rawValue].isEnabled = false
        }
    }
    

}
