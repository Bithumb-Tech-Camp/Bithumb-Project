//
//  CoinListService.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/04.
//

import Foundation

import RxCocoa
import RxSwift

final class CoinListService {
    
    func fetchCoinList(_ coinListType: CoinListType, _ changeRatePeriod: ChangeRatePeriod) -> Observable<[Coin]> {
        
        print(coinListType.rawValue, changeRatePeriod.rawValue)
        
        return .just([
            Coin(name: "BTC_KRW", currency: .KRW),
            Coin(name: "BTC_KRW", currency: .KRW),
            Coin(name: "BTC_KRW", currency: .KRW),
            Coin(name: "BTC_KRW", currency: .KRW),
            Coin(name: "BTC_KRW", currency: .KRW),
            Coin(name: "BTC_KRW", currency: .KRW)
        ])
    }
    
}
