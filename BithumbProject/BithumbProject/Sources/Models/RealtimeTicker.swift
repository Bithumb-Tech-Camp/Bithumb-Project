//
//  RealtimeTicker.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/23.
//

import Foundation

struct RealtimeTicker: Codable {
    var symbol: String?
    var tickType: String?
    var date: String?
    var time: String?
    var openPrice: String?
    var closePrice: String?
    var lowPrice: String?
    var highPrice: String?
    var value: String?
    var volume: String?
    var sellVolume: String?
    var buyVolume: String?
    var prevClosePrice: String?
    var changeRate: String?
    var changeAmount: String?
    var volumePower: String?
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case tickType
        case date
        case time
        case openPrice
        case closePrice
        case lowPrice
        case highPrice
        case value
        case volume
        case sellVolume
        case buyVolume
        case prevClosePrice
        case changeRate = "chgRate"
        case changeAmount = "chgAmt"
        case volumePower
    }
}
