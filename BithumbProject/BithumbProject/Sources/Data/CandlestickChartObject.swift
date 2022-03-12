//
//  Chart.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/11.
//

import Foundation

import RealmSwift

final class CandlestickChartObject: Object {
    @Persisted(primaryKey: true) var symbol: String
    @Persisted var data: List<CandlestickObject> = List<CandlestickObject>()
    
    convenience init(symbol: String, data: List<CandlestickObject>) {
        self.init()
        self.symbol = symbol
        self.data = data
    }
}
