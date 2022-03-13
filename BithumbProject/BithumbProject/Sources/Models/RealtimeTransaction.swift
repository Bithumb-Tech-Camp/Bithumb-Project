//
//  RealtimeTransaction.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/23.
//

import Foundation

struct RealtimeTransaction: Codable {
    var list: [RealtimeTransactionItem]?
}

struct RealtimeTransactionItem: Codable {
    var symbol: String?
    var buySellCategory: String?
    var contractPrice: String
    var contractQuantity: String?
    var contractAmount: String?
    var contractDatetime: String?
    var updown: String?

    enum CodingKeys: String, CodingKey {
        case symbol
        case buySellCategory = "buySellGb"
        case contractPrice = "contPrice"
        case contractQuantity = "contQty"
        case contractAmount = "contAmt"
        case contractDatetime = "contDtm"
        case updown = "updn"
    }
}
