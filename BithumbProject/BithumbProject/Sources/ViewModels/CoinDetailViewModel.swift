//
//  CoinDetailViewModel.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/02.
//

import Foundation
import RxSwift

final class CoinDetailViewModel: ViewModelType {
    
    struct Input {
        let fetchTicker: PublishSubject<Void> = PublishSubject<Void>()
        let fetchRealtimeTicker: PublishSubject<Void> = PublishSubject<Void>()
    }
    
    struct Output {
        let realtimeClosePriceText: BehaviorSubject<String> = BehaviorSubject<String>(value: "")
        let realtimeChangeAmountText: BehaviorSubject<String> = BehaviorSubject<String>(value: "")
        let realtimeChangeRateText: BehaviorSubject<String> = BehaviorSubject<String>(value: "")
        let realtimeUpDown: BehaviorSubject<UpDown> = BehaviorSubject<UpDown>(value: .up)
    }
    
    let input: Input
    let output: Output
    
    init() {
        self.input = Input()
        self.output = Output()
    }
}
