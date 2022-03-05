//
//  Coin.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/25.
//

import Foundation
import UIKit

struct Coin {
    enum Currency: String {
        case KRW
        case BTC
    }
    let krName: String
    let acronyms: String
    var currency: Currency = .KRW
    var ticker: Double
    var changeRate: ChangeRate
    var transaction: Double
    var isHigher: Bool
}

extension Coin {
    var symbol: String {
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
