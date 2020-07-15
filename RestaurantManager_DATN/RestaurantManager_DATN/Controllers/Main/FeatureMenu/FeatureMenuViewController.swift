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
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        App.shared.transitionToLoginView()
    }
    

}
