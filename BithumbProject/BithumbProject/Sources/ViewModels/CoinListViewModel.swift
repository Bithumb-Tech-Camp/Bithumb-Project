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
        
    }
    
    struct Output {
        let changeRates = BehaviorRelay<[ChangeRate]>(value: [])
    }
    
    var input: Input
    var output: Output
    
    init() {
        self.input = Input()
        self.output = Output()
        
        
    }
    
    private initialChangeRates() -> Observable<[ChangeRate]> {
        let chageRates = [
            ChangeRate(time: .Day, isSelected: <#T##Bool#>)
        ]
    }
    
}
