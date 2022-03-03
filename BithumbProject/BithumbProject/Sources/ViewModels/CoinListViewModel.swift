//
//  CoinListViewModel.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/26.
//

import Foundation

import RxCocoa
import RxSwift

final class CoinListViewModel: ViewModelType {
    
    struct Input {
        let selectedChangeRatePeriod = PublishRelay<ChangeRatePeriod>()
    }
    
    struct Output {
        let changeRatePeriodList = BehaviorRelay<[ChangeRatePeriod]>(value: ChangeRatePeriod.allCases)
        let currentChangeRatePeriod = BehaviorRelay<ChangeRatePeriod>(value: .MID)
    }
    
    var input: Input
    var output: Output
    var disposeBag = DisposeBag()
    
    init() {
        self.input = Input()
        self.output = Output()
        self.inputBinding(self.input)
        self.outputBinding(self.output)
    }
    
    func inputBinding(_ event: Input) {
        event.selectedChangeRatePeriod
            .bind(onNext: { period in
                // 바로 바인딩 하지 않음 
                self.output.currentChangeRatePeriod.accept(period)
            })
            .disposed(by: self.disposeBag)
    }
    
    func outputBinding(_ event: Output) {
        
    }
    
}
