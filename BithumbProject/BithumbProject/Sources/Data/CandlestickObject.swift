//
//  CandlestickObject.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/11.
//

import Foundation

import RealmSwift

final class CandlestickObject: Object {
    @Persisted(primaryKey: true) var uuid: UUID = UUID()
    @Persisted var symbol: String
    @Persisted var standardTime: Int64
    @Persisted var openPrice: Double
    @Persisted var closePrice: Double
    @Persisted var lowPrice: Double
    @Persisted var highPrice: Double
    @Persisted var volume: Double
    
    convenience init(
        symbol: String,
        standardTime: Int64,
        openPrice: Double,
        closePrice: Double,
        lowPrice: Double,
        highPrice: Double,
        volume: Double
    ) {
        self.init()
        self.symbol = symbol
        self.standardTime = standardTime
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.volume = volume
    }
    
    var toCandlestick: Candlestick {
        Candlestick(
            standardTime: UInt64(standardTime),
            openPrice: String(openPrice),
            closePrice: String(closePrice),
            lowPrice: String(lowPrice),
            highPrice: String(highPrice),
            transactionVolume: String(volume)
        )
    }
}
