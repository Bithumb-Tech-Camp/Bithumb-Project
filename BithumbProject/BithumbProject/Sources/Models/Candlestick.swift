//
//  Candlestick.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/23.
//

import Foundation

enum ChartInterval: Hashable {

    case minute(Int)
    case hour(Int)
    case day
    case week
    case month
    
    init?(tag: Int) {
        switch tag {
        case 100...199:
            self = .minute(tag % 100)
        case 200...299:
            self = .hour(tag % 100)
        case 300:
            self = .day
        case 400:
            self = .week
        case 500:
            self = .month
        default:
            return nil
        }
    }
    
    var toAPI: String {
        switch self {
        case .minute(let val):
            return "\(val)m"
        case .hour(let val):
            return "\(val)h"
        case .day:
            return "24h"
        case .week:
            return "24h"
        case .month:
            return "24h"
        }
    }
    
    var toKorean: String {
        switch self {
        case .minute(let val):
            return "\(val)분"
        case .hour(let val):
            return "\(val)시"
        case .day:
            return "일"
        case .week:
            return "주"
        case .month:
            return "월"
        }
    }
    
    var toTag: Int {
        switch self {
        case .minute(let val):
            return 100 + val
        case .hour(let val):
            return 200 + val
        case .day:
            return 300
        case .week:
            return 400
        case .month:
            return 500
        }
    }
}

struct Candlestick {
    var standardTime: UInt64?
    var openPrice: String?
    var closePrice: String?
    var lowPrice: String?
    var highPrice: String?
    var transactionVolume: String?
    
    var safeStandardTime: UInt64 {
        standardTime ?? 0
    }
    var safeOpenPrice: Double {
        Double(openPrice ?? "0") ?? 0
    }
    var safeClosePrice: Double {
        Double(closePrice ?? "0") ?? 0
    }
    var safeLowPrice: Double {
        Double(lowPrice ?? "0") ?? 0
    }
    var safeHighPrice: Double {
        Double(highPrice ?? "0") ?? 0
    }
    var safeTransactionVolume: Double {
        Double(transactionVolume ?? "0") ?? 0
    }
    var updown: UpDown {
        safeOpenPrice <= safeClosePrice ? .up : .down
    }
    
    init(
        standardTime: UInt64?,
        openPrice: String?,
        closePrice: String?,
        lowPrice: String?,
        highPrice: String?,
        transactionVolume: String?
    ) {
        self.standardTime = standardTime
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.transactionVolume = transactionVolume
    }
    
    init(array: [IntString]) {
        array.enumerated().forEach { index, val in
            switch (index, val) {
            case (0, .int(let data)):
                self.standardTime = data
            case (1, .string(let data)):
                self.openPrice = data
            case (2, .string(let data)):
                self.closePrice = data
            case (3, .string(let data)):
                self.lowPrice = data
            case (4, .string(let data)):
                self.highPrice = data
            case (5, .string(let data)):
                self.transactionVolume = data
            default:
                break
            }
        }
    }
}
