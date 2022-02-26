//
//  TransactionHistory.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/27.
//

import Foundation

struct TransactionHistory: Codable {
    var transaction_date: String?
    var type: String?
    var units_traded: String?
    var price: String?
    var total: String?
    
    enum CodingKeys: String, CodingKey {
        case transaction_date
        case type
        case units_traded = "unitsTraded"
        case price
        case total
    }
}
