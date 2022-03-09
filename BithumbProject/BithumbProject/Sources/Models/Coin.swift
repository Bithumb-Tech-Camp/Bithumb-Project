//
//  Coin.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/25.
//

import Foundation
import UIKit

final class Coin {
    enum Currency: String {
        case KRW
        case BTC
    }
    var krName: String
    var acronyms: String
    var currency: Currency
    var ticker: Double
    var changeRate: ChangeRate
    var transaction: Double
    var isStarred: Bool
    var isHigher: Bool?
    var tickType: ChangeRatePeriod
    
    init(krName: String = "비트코인",
         acronyms: String = "BTC",
         currency: Currency = .KRW,
         ticker: Double,
         changeRate: ChangeRate,
         transaction: Double,
         isStarred: Bool = false,
         isHigher: Bool? = nil,
         tickType: ChangeRatePeriod = .MID) {
        self.krName = krName
        self.acronyms = acronyms
        self.currency = currency
        self.ticker = ticker
        self.changeRate = changeRate
        self.transaction = transaction
        self.isStarred = isStarred
        self.isHigher = isHigher
        self.tickType = tickType
    }
}

extension Coin {
    var symbol: String {
        return "\(self.acronyms)/\(self.currency.rawValue)"
    }
    
    var orderCurrency: OrderCurrency {
        return "\(self.acronyms)_\(self.currency.rawValue)"
    }
    
    var updateColor: UIColor? {
        if let isHigher = self.isHigher {
            let color: UIColor = isHigher ? .systemRed : .systemBlue
            return color
        } else {
            return nil
        }
    }
}

extension Coin: Equatable {
    static func == (lhs: Coin, rhs: Coin) -> Bool {
        return lhs.acronyms == rhs.acronyms
    }
}

extension Coin: Comparable {
    static func < (lhs: Coin, rhs: Coin) -> Bool {
        return lhs.ticker < rhs.ticker
    }
}
