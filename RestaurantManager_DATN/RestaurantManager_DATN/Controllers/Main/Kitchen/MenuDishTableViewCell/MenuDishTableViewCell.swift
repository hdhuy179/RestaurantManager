//
//  DishViewCell.swift
//  Firebase_demo
//
//  Created by Hoang Dinh Huy on 10/23/19.
//  Copyright © 2019 Hoang Dinh Huy. All rights reserved.
//

final class MenuDishTableViewCell: UITableViewCell {

    @IBOutlet weak var dishProfileImage: UIImageView!
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var dishPriceLabel: UILabel!
    @IBOutlet weak var dishUnitLabel: UILabel!
    @IBOutlet weak var swInMenu: UISwitch!
    var dish: MonAn!
    
    func configView(data: MonAn) {
        dish = data
        if let url = URL(string: data.diachianh) {
            dishProfileImage.kf.setImage(with: url)
        }
        dishNameLabel.text = data.tenmonan
        dishUnitLabel.text = data.donvimonan
        if data.dongia > 0 {
            dishPriceLabel.text = data.dongia.splittedByThousandUnits()
        }
        swInMenu.isOn = dish?.trongthucdon == 1
    }
    @IBAction func swInMenuChanged(_ sender: Any) {
        dish.trongthucdon = swInMenu.isOn ? 1 : 0
        dish.updateInMenu(forDish: dish) { (err) in
            print(err ?? "")
        }
    }
}
