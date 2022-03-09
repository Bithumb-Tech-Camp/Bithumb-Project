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
    
    func changeRate(from: String) -> String {
        guard let from = Double(from) else { return "" }
        guard let to = Double(self) else { return "" }
        if from < to {
            return "+"+String(format: "%.2f", round( ((to - from) / from) * 10000 ) / 100) + "%"
        }
        return String(format: "%.2f", round( ((to - from) / from) * 10000 ) / 100) + "%"
    }
    
    var displayToBillions: String? {
        guard var number = Double(self) else { return nil }
        number = round(trunc(number) / 10000000) / 10
        return String(format: "%.3f", number) + " 억"
    }
    
    var displayToCoin: String? {
        guard var number = Double(self) else { return nil }
        number = round(number * 1000) / 1000
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(for: number)
    }
}
