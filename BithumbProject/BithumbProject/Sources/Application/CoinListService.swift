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
    
    var coinList = [
        Coin(
            krName: "비트코인",
            acronyms: "BTC",
            ticker: 49991249,
            changeRate: ChangeRate(rate: -0.23, amount: -112515),
            transaction: 45124512),
        Coin(
            krName: "연파이낸스",
            acronyms: "YFI",
            ticker: 24564000,
            changeRate: ChangeRate(rate: -4.58, amount: -2321000),
            transaction: 1353000),
        Coin(
            krName: "이더리움",
            acronyms: "ETM",
            ticker: 49991249,
            changeRate: ChangeRate(rate: -0.23, amount: -112515),
            transaction: 45124512),
        Coin(
            krName: "메이커",
            acronyms: "MKR",
            ticker: 49991249,
            changeRate: ChangeRate(rate: -0.23, amount: -112515),
            transaction: 45124512),
        Coin(
            krName: "바이낸스코인",
            acronyms: "BNB",
            ticker: 49991249,
            changeRate: ChangeRate(rate: -0.23, amount: -112515),
            transaction: 45124512)
    ]
    
    func fetchCoinList(_ coinListType: CoinListType, _ changeRatePeriod: ChangeRatePeriod) -> Observable<[Coin]> {
        
        print(coinListType.rawValue, changeRatePeriod.rawValue)
        
        self.coinList += coinList
        
        return .just(coinList)
    }
}
