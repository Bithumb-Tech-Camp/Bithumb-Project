//
//  CoinDetailViewModel.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/02.
//

import Foundation
import RxSwift
import RxRelay

final class CoinDetailViewModel: ViewModelType {
    
    struct Input {
        let fetchTicker: PublishSubject<Void> = PublishSubject<Void>()
        let fetchRealtimeTicker: PublishSubject<Void> = PublishSubject<Void>()
    }
    
    struct Output {
        let realtimeClosePriceText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        let realtimeChangeAmountText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        let realtimeChangeRateText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        let realtimeUpDown: BehaviorRelay<UpDown> = BehaviorRelay<UpDown>(value: .up)
        let error: PublishRelay<NSError> = PublishRelay<NSError>()
    }
    
    let input: Input
    let output: Output
    
    init() {
        self.input = Input()
        self.output = Output()
    }
}
