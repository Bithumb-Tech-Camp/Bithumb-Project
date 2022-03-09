//
//  ChangeRatePeriod.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/03.
//

import Foundation

enum ChangeRatePeriod: String, CaseIterable {
    case MID = "어제대비"
    case day = "24시간"
    case halfDay = "12시간"
    case hour = "1시간"
    case halfHour = "30분"
    
    var param: String {
        switch self {
        case .MID:
            return "MID"
        case .day:
            return "24H"
        case .halfDay:
            return "12H"
        case .hour:
            return "1H"
        case .halfHour:
            return "30M"
        }
    }
}

extension ChangeRatePeriod: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.MID, .MID),
            (.day, .day),
            (.halfDay, .halfDay),
            (.hour, .hour),
            (.halfHour, .halfHour):
            return true
        default:
            return false
        }
    }
}
