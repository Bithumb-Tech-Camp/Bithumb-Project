//
//  String+Extension.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/02/24.
//

import Foundation

extension String {
    
    func changeDateFormat(from: String, to: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = from
        formatter.locale = Locale(identifier: "ko")
        
        if let date = formatter.date(from: self) {
            formatter.dateFormat = to
            return formatter.string(from: date)
        } else {
            return nil
        }
    }
    
    func stringToDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko")
        return formatter.date(from: self)
    }
    
    var decimal: String? {
        guard let number = Int(self) else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(for: Int(number))
    }
    
    var rounded: String? {
        guard let number = Double(self) else { return nil }
        return String(format: "%.4f", round(number * 10000) / 10000)
    }
}
