//
//  HoldingsViewModel.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/09.
//

import Foundation

import RxCocoa
import RxSwift

final class HoldingsViewModel: ViewModelType {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var input: Input
    var output: Output
    var disposeBag = DisposeBag()
    let httpManager: HTTPManager
    let webSocketManager: WebSocketManager
    
    init(httpManager: HTTPManager,
         webSocketManager: WebSocketManager) {
        self.input = Input()
        self.output = Output()
        self.httpManager = httpManager
        self.webSocketManager = webSocketManager
        
    }
    
}
