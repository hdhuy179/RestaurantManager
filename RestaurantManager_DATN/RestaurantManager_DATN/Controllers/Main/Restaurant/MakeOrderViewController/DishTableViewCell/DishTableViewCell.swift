//
//  DishViewCell.swift
//  Firebase_demo
//
//  Created by Hoang Dinh Huy on 10/23/19.
//  Copyright © 2019 Hoang Dinh Huy. All rights reserved.
//

final class DishTableViewCell: UITableViewCell {

    @IBOutlet weak var dishProfileImage: UIImageView!
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var dishPriceLabel: UILabel!
    @IBOutlet weak var dishUnitLabel: UILabel!
    @IBOutlet weak var dishAmountLabel: UILabel!
//    @IBOutlet weak var dishDescriptionLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    weak var delegate: OrderViewControllerDelegate?

    var dish: MonAn!

    var amount: Int! = 0 {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        dishAmountLabel.text = String(amount)
        if amount == 0 {
            dishAmountLabel.alpha = 0
            minusButton.alpha = 0
        } else {
            dishAmountLabel.alpha = 1
            minusButton.alpha = 1
        }
    }
    
    func configView(data: MonAn, amount: Int? = 0) {
        dish = data
        if let url = URL(string: data.diachianh) {
            dishProfileImage.kf.setImage(with: url)
        }
        dishNameLabel.text = data.tenmonan
        dishUnitLabel.text = data.donvimonan
        if data.dongia > 0 {
            dishPriceLabel.text = data.dongia.splittedByThousandUnits()
        }
        self.amount = amount
    }

    @IBAction func handlePlusButtonTapped(_ sender: Any) {
        if amount >= 99 {
            return
        }
        amount += 1
        delegate?.changeOrderAmount(dish: dish, amount: amount)
        updateView()
    }
    
    @IBAction func handleMinusButtonTapped(_ sender: Any) {
        if amount > 0 {
            amount -= 1
        }
        delegate?.changeOrderAmount(dish: dish, amount: amount)
        updateView()
    }
}
