//
//  BarChartObject.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/11.
//

import Foundation

import RealmSwift

final class BarChartObject: Object {
    @Persisted(primaryKey: true) var symbol: String
    @Persisted var data: List<BarObject> = List<BarObject>()
    
    convenience init(symbol: String, data: List<BarObject>) {
        self.init()
        self.symbol = symbol
        self.data = data
    }
}
