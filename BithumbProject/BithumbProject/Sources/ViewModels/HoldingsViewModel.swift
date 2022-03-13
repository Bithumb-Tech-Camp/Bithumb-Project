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
        
        let user = User(
            name: CommonUserDefault<String>.fetch(.username).first ?? "",
            assets: Double(CommonUserDefault<String>.fetch(.holdings).first ?? "") ?? 0.0)
        
        Observable.just(user)
            .bind(to: self.output.userInfo)
            .disposed(by: self.disposeBag)
        
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
