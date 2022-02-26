//
//  OrderBook.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/27.
//

import Foundation

struct OrderBook: Codable {
    var timestamp: String?
    var order_currency: String?
    var payment_currency: String?
    var bids: [BidAsk]?
    var asks: [BidAsk]?
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case order_currency = "orderCurrency"
        case payment_currency = "paymentCurrency"
        case bids
        case asks
    }
}

struct BidAsk: Codable {
    var quantity: String?
    var price: String?
}
