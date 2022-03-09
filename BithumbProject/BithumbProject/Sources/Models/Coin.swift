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
    let krName: String
    let acronyms: String
    var currency: Currency
    var ticker: Double
    var changeRate: ChangeRate
    var transaction: Double
    var isStarred: Bool
    var isHigher: Bool
    
    init(krName: String,
         acronyms: String,
         currency: Currency = .KRW,
         ticker: Double,
         changeRate: ChangeRate,
         transaction: Double,
         isStarred: Bool = false,
         isHigher: Bool = false) {
        self.krName = krName
        self.acronyms = acronyms
        self.currency = currency
        self.ticker = ticker
        self.changeRate = changeRate
        self.transaction = transaction
        self.isStarred = isStarred
        self.isHigher = isHigher
    }
}

extension Coin {
    var symbol: String {
        return "\(self.acronyms)/\(self.currency.rawValue)"
    }
    
    var orderCurrency: OrderCurrency {
        return "\(self.acronyms)_\(self.currency.rawValue)"
    }
    
    var updateColor: UIColor {
        if self.isHigher {
            return .systemRed
        } else {
            return .systemBlue
        }
    }
}

extension Coin: Equatable {
    static func == (lhs: Coin, rhs: Coin) -> Bool {
        return lhs.acronyms == rhs.acronyms && lhs.krName == rhs.krName
    }
}

extension Coin: Comparable {
    static func < (lhs: Coin, rhs: Coin) -> Bool {
        return lhs.ticker < rhs.ticker
    }
}
