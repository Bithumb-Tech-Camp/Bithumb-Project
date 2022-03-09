//
//  Ticker.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/23.
//

import Foundation

struct Ticker: Codable {
    var openingPrice: String?
    var closingPrice: String?
    var minPrice: String?
    var maxPrice: String?
    var unitsTraded: String?
    var accTradeValue: String?
    var prevClosingPrice: String?
    var unitsTraded24H: String?
    var accTradeValue24H: String?
    var fluctate24H: String?
    var fluctateRate24H: String?
    var date: String?
    
    enum CodingKeys: String, CodingKey {
        case openingPrice = "opening_price"
        case closingPrice = "closing_price"
        case minPrice = "min_price"
        case maxPrice = "max_price"
        case unitsTraded = "units_traded"
        case accTradeValue = "acc_trade_value"
        case prevClosingPrice = "prev_closing_price"
        case unitsTraded24H = "units_traded_24H"
        case accTradeValue24H = "acc_trade_value_24H"
        case fluctate24H = "fluctate_24H"
        case fluctateRate24H = "fluctate_rate_24H"
        case date
    }
}

extension Ticker {
    func toDomain() -> Coin {
        let ticker = Double(self.closingPrice ?? "") ?? 0.0
        let rate = Double(self.fluctateRate24H ?? "") ?? 0.0
        let amount = Double(self.fluctate24H ?? "") ?? 0
        let changeRate = ChangeRate(rate: rate, amount: amount)
        let transaction = Double(self.accTradeValue24H ?? "") ?? 0.0
        return .init(ticker: ticker, changeRate: changeRate, transaction: transaction)
    }
}
