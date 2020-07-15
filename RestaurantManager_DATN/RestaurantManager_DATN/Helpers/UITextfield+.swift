//
//  UITextfield+.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 6/18/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

var minimumDate: Date?
var maximumDate: Date?
var dateFormat: String?

var mode:UIDatePicker.Mode = .dateAndTime

extension UITextField {
    
    func isDatePickerTextField(minimumDate min: Date? = nil, maximumDate max: Date? = Date(), dateFormat format: String? = "dd/MM/yyyy hh:mm:ss") {
    
        minimumDate = min
        maximumDate = max
        dateFormat = format
        
        if dateFormat == "dd/MM/yyyy" {
            mode = .date
        }
        
        self.addTarget(self, action: #selector(textFieldEditing), for: .editingDidBegin)

        if let view = self.superview {
            
            let toolBar = UIToolbar()
            toolBar.frame.size.width = view.frame.size.width
            toolBar.frame.size.height = 40.0
            toolBar.barStyle = .black
            toolBar.tintColor = .white
            toolBar.backgroundColor = .black

            let todayBtn = UIBarButtonItem(title: "Hôm nay", style: .plain, target: self, action: #selector(tappedToolBarBtn))
            let okBarBtn = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(donePressed))
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

            let label = UILabel()
            label.font = UIFont(name: "Helvetica", size: 15)
            label.backgroundColor = .clear
            label.textColor = .white
            label.text = "Chọn ngày"
            label.textAlignment = .center
            
            let textBtn = UIBarButtonItem(customView: label)
            toolBar.setItems([todayBtn,flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
            self.inputAccessoryView = toolBar
        }
    }
    
    @objc func tappedToolBarBtn(sender: UIBarButtonItem) {
        self.text = getFormattedDate(date: Date())
        self.resignFirstResponder()
    }

    @objc func donePressed(sender: UIBarButtonItem) {
        self.text = nil
        self.resignFirstResponder()

    }

    @objc func textFieldEditing(_ sender: UITextField) {
        let datePicker: UIDatePicker = UIDatePicker()
        
        datePicker.datePickerMode = mode
        
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        sender.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
        
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        
        self.text = getFormattedDate(date: sender.date)
    }
    
    func getFormattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
}
