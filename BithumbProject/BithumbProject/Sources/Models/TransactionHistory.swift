//
//  TransactionHistory.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/27.
//

import Foundation

struct TransactionHistory: Codable {
    var transactionDate: String?
    var type: String?
    var unitsTraded: String?
    var price: String?
    var total: String?
    var updown: String?
    
    enum CodingKeys: String, CodingKey {
        case transactionDate = "transaction_date"
        case type
        case unitsTraded = "units_traded"
        case price
        case total
        case updown
    }
}
