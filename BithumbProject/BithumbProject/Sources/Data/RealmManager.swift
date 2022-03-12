//
//  ChartService.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/12.
//

import Foundation

import RealmSwift

final class RealmManager {
    
    private let realm: Realm? = try? Realm()
    
    func findCandlestickChartObject(symbol: String) -> CandlestickChartObject? {
        guard let realm = realm,
              let object = realm.object(ofType: CandlestickChartObject.self, forPrimaryKey: symbol) else {
            return nil
        }
        return object
    }
    
    func findOrCreateIfNilCandlestickChartObject(symbol: String) -> CandlestickChartObject? {
        if let object = findCandlestickChartObject(symbol: symbol) {
            return object
        }
        return createCandlestickChartObject(symbol: symbol, data: List<CandlestickObject>())
    }
    
    func findCandlestickObject(symbol: String, standardTime: Int64) -> CandlestickObject? {
        guard let object = findCandlestickChartObject(symbol: symbol) else {
            return nil
        }
        return object.data
            .where { $0.standardTime == standardTime }
            .first
    }
    
    func findCandlestickObject(candlestickChartObject: CandlestickChartObject?, standardTime: Int64) -> CandlestickObject? {
        guard let chartObject = candlestickChartObject else {
            return nil
        }
        return chartObject.data
            .where { $0.standardTime == standardTime }
            .first
    }
    
    func findBarChartObject(symbol: String) -> BarChartObject? {
        guard let realm = realm,
              let object = realm.object(ofType: BarChartObject.self, forPrimaryKey: symbol) else {
            return nil
        }
        return object
    }
    
    func findOrCreateIfNilBarChartObject(symbol: String) -> BarChartObject? {
        if let object = findBarChartObject(symbol: symbol) {
            return object
        }
        return createBarChartObject(symbol: symbol, data: List<BarObject>())
    }
    
    func findBarObject(symbol: String, standardTime: Int64) -> BarObject? {
        guard let object = findBarChartObject(symbol: symbol) else {
            return nil
        }
        return object.data
            .where { $0.standardTime == standardTime }
            .first
    }
    
    func findBarObject(barChartObject: BarChartObject?, standardTime: Int64) -> BarObject? {
        guard let chartObject = barChartObject else {
            return nil
        }
        return chartObject.data
            .where { $0.standardTime == standardTime }
            .first
    }
    
    func createCandlestickChartObject(symbol: String, data: List<CandlestickObject>) -> CandlestickChartObject? {
        guard let realm = realm else {
            return nil
        }
        let candlestickChartObject = CandlestickChartObject(symbol: symbol, data: data)
        try? realm.write {
            realm.add(candlestickChartObject)
        }
        return candlestickChartObject
    }
    
    func createBarChartObject(symbol: String, data: List<BarObject>) -> BarChartObject? {
        guard let realm = realm else {
            return nil
        }
        let barChartObject = BarChartObject(symbol: symbol, data: data)
        try? realm.write {
            realm.add(barChartObject)
        }
        return barChartObject
    }
    
    func addCandlestickObject(symbol: String, newData: CandlestickObject) {
        guard let realm = realm, let object = findCandlestickChartObject(symbol: symbol) else {
            return
        }
        try? realm.write {
            object.data.append(newData)
        }
    }
    
    func addBarObject(symbol: String, newData: BarObject) {
        guard let realm = realm, let object = findBarChartObject(symbol: symbol) else {
            return
        }
        try? realm.write {
            object.data.append(newData)
        }
    }
}
