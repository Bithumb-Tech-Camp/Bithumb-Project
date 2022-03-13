//
//  CandlestickObject.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/11.
//

import Foundation

import RealmSwift

final class CandlestickObject: Object {
    @Persisted(primaryKey: true) var standardTime: Int64
    @Persisted var openPrice: Double
    @Persisted var closePrice: Double
    @Persisted var lowPrice: Double
    @Persisted var highPrice: Double
    
    convenience init(
        standardTime: Int64,
        openPrice: Double,
        closePrice: Double,
        lowPrice: Double,
        highPrice: Double
    ) {
        self.init()
        self.standardTime = standardTime
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
    }
}
