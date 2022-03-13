//
//  RealmService.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/13.
//

import Foundation

import RealmSwift

final class RealmService {
    
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
    
    func findCandlestickObject(_ candlestickChartObject: CandlestickChartObject?, standardTime: Int64, symbol: String) -> CandlestickObject? {
        guard let chartObject = candlestickChartObject else {
            return nil
        }
        return chartObject.data
            .where { $0.standardTime == standardTime && $0.symbol == symbol }
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
    
    func addCandlestickObject(_ candlestickChartObject: CandlestickChartObject?, newDatas: [CandlestickObject]) {
        guard let candlestickChartObject = candlestickChartObject else {
            return
        }
        ThreadSafeReference(to: candlestickChartObject).async(write: true) { _, obj in
            var unsavedDatas: [CandlestickObject] = []
            for newData in newDatas {
                if nil != self.findCandlestickObject(obj, standardTime: newData.standardTime, symbol: newData.symbol) {
                    continue
                }
                unsavedDatas.append(newData)
            }
            obj.data.append(objectsIn: unsavedDatas)
        }
    }
}

extension DispatchQueue {
    public static let realmBackgroundQueue = DispatchQueue(label: "io.realm.realm.background")
}

extension ThreadSafeReference {
    func async(
        write: Bool = false, queue: DispatchQueue = .realmBackgroundQueue,
        errorHandler: ((Realm.Error) -> Void)? = nil,
        block: @escaping (Realm, Confined) -> Void
    ) {
        queue.async {
            do {
                let realm = try Realm()
                if let obj = realm.resolve(self) {
                    if write { realm.beginWrite() }
                    block(realm, obj)
                    if write { try realm.commitWrite() }
                } else {
                    
                }
            } catch {
                
            }
        }
    }
}
