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
        let userInfo = BehaviorRelay<User?>(value: nil)
        let holdings = BehaviorRelay<[Holdings]>(value: [])
    }
    
    var input: Input
    var output: Output
    var disposeBag = DisposeBag()
    let httpManager: HTTPManager
    
    init(httpManager: HTTPManager) {
        self.input = Input()
        self.output = Output()
        self.httpManager = httpManager
        
        httpManager.request(httpServiceType: .assetsStatus("All"), model: [String: AssetsStatus].self)
            .map { $0.map { name, assetsStatus -> Holdings in
                let holdings = assetsStatus.toDomain()
                holdings.coinName = "\(name)코인"
                return holdings
            }}
            .subscribe(onNext: { [weak self] value in
                self?.output.holdings.accept(value)
            })
            .disposed(by: self.disposeBag)
    }
}
