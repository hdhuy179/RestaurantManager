//
//  Float+.swift
//  RestaurantManager_DATN
//
//  Created by HuyHoangDinh on 7/24/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import Foundation

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
