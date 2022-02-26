//
//  OrderBook.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/27.
//

import Foundation

struct OrderBook: Codable {
    var timestamp: String?
    var orderCurrency: String?
    var paymentCurrency: String?
    var bids: [BidAsk]?
    var asks: [BidAsk]?
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case orderCurrency = "order_currency"
        case paymentCurrency = "payment_currency"
        case bids
        case asks
    }
}

struct BidAsk: Codable {
    var quantity: String?
    var price: String?
}
