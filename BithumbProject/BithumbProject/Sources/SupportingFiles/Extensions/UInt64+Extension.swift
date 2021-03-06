//
//  UInt64+Extension.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/06.
//

import Foundation

extension UInt64 {
    func date(format: String) -> String? {
        let date = Date(timeIntervalSince1970: Double(self) * 0.001)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
