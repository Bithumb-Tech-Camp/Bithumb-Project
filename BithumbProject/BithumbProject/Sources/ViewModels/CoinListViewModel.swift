//
//  CoinListViewModel.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/26.
//

import Foundation

final class CoinListViewModel: ViewModelType {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var input: Input
    var output: Output
    
    init() {
        self.input = Input()
        self.output = Output()
    }
    
}
