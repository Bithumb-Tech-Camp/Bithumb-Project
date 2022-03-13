//
//  ChartService.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/12.
//

import Foundation
import RxSwift

final class RealmManager {
    
    private let realmService: RealmService = RealmService()
    
    func requestCandlesticks(option: ChartOption) -> Observable<[Candlestick]> {
        let candlestickChartObject = realmService.findOrCreateIfNilCandlestickChartObject(symbol: option.orderCurrency)
        let date = Date()
        return Observable.create {[weak self] observer in
            guard let self = self else { return Disposables.create() }
            switch option.interval {
            case .minute:
                observer.onNext([])
                observer.onCompleted()
            case .hour(24), .day:
                observer.onNext([])
                observer.onCompleted()
                return Disposables.create()
                
                let currentHour = date.currentHour
                let beforeHour = date.beforeHour(hour: 24)
                
                if let recentCandlestickObject = self.realmService.findCandlestickObject(
                    candlestickChartObject,
                    standardTime: currentHour.timeIntervalSince1970ms,
                    symbol: option.orderCurrency
                ), let nextCandlestickObject = self.realmService.findCandlestickObject(
                    candlestickChartObject,
                    standardTime: beforeHour.timeIntervalSince1970ms,
                    symbol: option.orderCurrency
                ) {
                    var result: [Candlestick] = [
                        recentCandlestickObject.toCandlestick,
                        nextCandlestickObject.toCandlestick
                    ]
                    var interval = 1
                    while true {
                        let nextHour = date.hourBefore(date: beforeHour, interval: interval, nHour: 24)
                        if let candlestickObject = self.realmService.findCandlestickObject(
                            candlestickChartObject,
                            standardTime: nextHour.timeIntervalSince1970ms,
                            symbol: option.orderCurrency
                        ) {
                            result.append(candlestickObject.toCandlestick)
                        } else {
                            break
                        }
                        interval += 1
                    }
                    observer.onNext(result.reversed())
                    observer.onCompleted()
                } else {
                    observer.onNext([])
                    observer.onCompleted()
                }
            default:
                return Disposables.create()
            }
            return Disposables.create()
        }
    }
    
    func saveCandlesticks(option: ChartOption, candlesticks: [Candlestick]) {
        let candlestickChartObject = realmService.findOrCreateIfNilCandlestickChartObject(symbol: option.orderCurrency)
        let newDatas = candlesticks.map { candlestick in
            CandlestickObject(
                symbol: option.orderCurrency,
                standardTime: Int64(candlestick.standardTime ?? 0),
                openPrice: candlestick.safeOpenPrice,
                closePrice: candlestick.safeClosePrice,
                lowPrice: candlestick.safeLowPrice,
                highPrice: candlestick.safeHighPrice,
                volume: candlestick.safeTransactionVolume
            )
        }
        realmService.addCandlestickObject(candlestickChartObject, newDatas: newDatas)
    }
}
