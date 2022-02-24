//
//  Coin.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/25.
//

import Foundation

struct Coin {
    enum Currency: String {
        case KRW
        case BTC
    }
    var name: String
    var currency: Currency = .KRW
}

extension Coin {
    var symbol: String {
        return "\(self.name)_\(self.currency.rawValue)"
    }
}
