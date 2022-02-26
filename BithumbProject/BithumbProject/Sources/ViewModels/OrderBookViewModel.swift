//
//  OrderBookViewModel.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/26.
//

import Foundation
import RxSwift
import RxCocoa

final class OrderBookViewModel: ViewModelType {

    var input: Input
    var output: Output
    var disposeBag: DisposeBag = DisposeBag()

    struct Input {
        let dummyData = PublishRelay<[RealtimeOrderBook]>()
    }
    
    struct Output {
        let dummyData = BehaviorRelay<[RealtimeOrderBook]>(value: [RealtimeOrderBook]())
    }
    
    init() {
        self.input = Input()
        self.output = Output()
        
        self.input.dummyData
            .bind(to: self.output.dummyData)
            .disposed(by: disposeBag)
    }
}
