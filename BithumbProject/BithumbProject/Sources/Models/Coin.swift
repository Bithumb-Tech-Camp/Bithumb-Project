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
    var isHigher: Bool?
    var wasHigher: Bool?
    var tickType: ChangeRatePeriod
    
    init(krName: String = "비트코인",
         acronyms: String = "BTC",
         currency: Currency = .KRW,
         ticker: Double,
         changeRate: ChangeRate,
         transaction: Double,
         isHigher: Bool? = nil,
         wasHigher: Bool? = nil,
         tickType: ChangeRatePeriod = .MID) {
        self.krName = krName
        self.acronyms = acronyms
        self.currency = currency
        self.ticker = ticker
        self.changeRate = changeRate
        self.transaction = transaction
        self.isHigher = isHigher
        self.wasHigher = wasHigher
        self.tickType = tickType
    }
    
    func star(_ isSelected: Bool) {
        let coinName = "\(self.acronyms)_\(self.currency.rawValue)"
        if isSelected {
            CommonUserDefault<String>.save(coinName, key: .star(coinName))
        } else {
            CommonUserDefault<String>.delete(.star(coinName))
        }
        
        let names = CommonUserDefault<String>.fetch(.username)
        print("👺 \(names)")
        
        let holdings = CommonUserDefault<String>.fetch(.holdings)
        print("👺 \(holdings)")
        
        let stars = CommonUserDefault<String>.fetch(.star(""))
        print("👺 \(stars)")
    }
}

extension Coin {
    var symbol: String {
        return "\(self.acronyms)/\(self.currency.rawValue)"
    }
    
    var orderCurrency: OrderCurrency {
        return "\(self.acronyms)_\(self.currency.rawValue)"
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
