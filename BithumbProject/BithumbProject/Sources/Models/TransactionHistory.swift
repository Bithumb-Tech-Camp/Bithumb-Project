//
//  TransactionHistory.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/27.
//

import Foundation
import UIKit

struct TransactionHistory: Codable {
    var transactionDate: String?
    var type: String?
    var unitsTraded: String?
    var price: String?
    var total: String?
    var updown: String?
    
    var date: Date {
        self.transactionDate?.stringToDate(format: "YYYY-MM-DD HH:mm:ss") ?? Date()
    }
    
    var formattedDate: String? {
        self.transactionDate?.changeDateFormat(from: "YYYY-MM-DD HH:mm:ss", to: "HH:mm:ss")
    }
    
    var formattedPrice: String? {
        self.price?.decimal
    }
    
    var formattedUnitsTraded: String? {
        self.unitsTraded?.roundedDecimal
    }
    
    var formattedUpdown: UpDown {
        self.updown == "dn" ? .down : .up
    }
    
    enum CodingKeys: String, CodingKey {
        case transactionDate = "transaction_date"
        case type
        case unitsTraded = "units_traded"
        case price
        case total
        case updown
    }
}
