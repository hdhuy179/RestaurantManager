//
//  Date+.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/17/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

extension Date {
    func convertToString(withDateFormat dateFormat: String? = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    func getDateFormatted(withDateFormat dateFormat: String? = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self.convertToString(withDateFormat: dateFormat))
    }
    
    static func getDate(fromString date: String, withDateFormat dateFormat: String? = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: date)
    }
    
    static func getDateArray(fromDate: Date, toDate: Date, byComponent: Calendar.Component, value: Int) -> [Date] {
        
        if fromDate.timeIntervalSince1970 > toDate.timeIntervalSince1970 {
            return []
        }
        
        let calender = Calendar.current
        var tempDate = fromDate
        var result = [tempDate]
        
        while tempDate.timeIntervalSince1970 < toDate.timeIntervalSince1970 {
            if let nextDate = calender.date(byAdding: byComponent, value: value, to: tempDate) {
                tempDate = nextDate
                result.append(tempDate)
            } else {
                break
            }
        }
        return result
    }
}
