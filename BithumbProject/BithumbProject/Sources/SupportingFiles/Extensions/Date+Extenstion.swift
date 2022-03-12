//
//  Date+Extenstion.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/12.
//

import Foundation

extension Date {
    var recentHourUnixTime: UInt64 {
//        let date = Date()
//        let dateFormatter = DateFormatter()
//
//        dateFormatter.date(from: <#T##String#>)
        
//        현재 날짜를 기준으로 그 전날 00시 unix timestamp
//        오늘: 12일
//        11일 00시 unix timestamp
//
//        date -> timestamp ???
//
//
//        전날 00시 date는?
        let date = Calendar.current.date(byAdding: .day, value: -1, to: self)
        date?.timeIntervalSince1970
        
        return UInt64(floor(self.timeIntervalSince1970 / 3600) * 3600000)
    }
}
