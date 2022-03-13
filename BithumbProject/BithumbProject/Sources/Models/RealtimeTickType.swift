//
//  RealtimeTickType.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/12.
//

import Foundation

enum RealtimeTickType: String {
    case thirtyMinute = "30M"
    case oneHour = "1H"
    case twelveHour = "12H"
    case twentyFourHour = "24H"
    case mid = "MID"
    
    init?(tickType: String) {
        let value = tickType.lowercased()
        switch value {
        case "1m", "3m", "5m", "10m", "30m":
            self = .thirtyMinute
        case "1h", "6h":
            self = .oneHour
        case "12h":
            self = .twelveHour
        case "24h", "mid":
            self = .twentyFourHour
        default:
            return nil
        }
    }
}
