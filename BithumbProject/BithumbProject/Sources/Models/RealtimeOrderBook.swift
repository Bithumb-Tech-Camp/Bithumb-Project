//
//  RealtimeOrderBook.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/23.
//

import Foundation

struct RealtimeOrderBook: Codable {
    var list: [RealtimeOrderbookDepth]?
    var datetime: String?
}

struct RealtimeOrderbookDepth: Codable {
    var symbol: String?
    var orderType: String?
    var price: String?
    var quantity: String?
    var total: String?
}
