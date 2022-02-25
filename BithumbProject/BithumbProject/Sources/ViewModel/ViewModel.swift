//
//  ViewModel.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/25.
//

import Foundation

final class ViewModel: ViewModelType {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var input: Input
    var output: Output
    let httpManager: HTTPManager
    
    init(httpManager: HTTPManager) {
        self.input = Input()
        self.output = Output()
        self.httpManager = httpManager
    }
    
    
}
