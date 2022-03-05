//
//  CoinListViewModel.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/26.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift

final class CoinListViewModel: ViewModelType {
    
    struct Input {
        let inputQuery = PublishRelay<String>()
        let searchButtonClicked = PublishRelay<Void>()
        let selectedCoinListType = BehaviorRelay<CoinListType>(value: .KRW)
        let selectedChangeRatePeriod = BehaviorRelay<ChangeRatePeriod>(value: .MID)
    }
    
    struct Output {
        let headerList: [SortedColumn]
        let coinList = BehaviorRelay<[SectionModel<Int, Coin>]>(value: [])
        let requestList = BehaviorRelay<[CoinListType]>(value: CoinListType.allCases)
        let changeRatePeriodList = BehaviorRelay<[ChangeRatePeriod]>(value: ChangeRatePeriod.allCases)
        let currentChangeRatePeriod = BehaviorRelay<ChangeRatePeriod>(value: .MID)
    }
    
    var input: Input
    var output: Output
    var disposeBag = DisposeBag()
    let coinListService: CoinListService
    private let sortedColums: [SortedColumn] = (0...3).map { .init(column: $0) }
    
    init(coinListService: CoinListService) {
        self.input = Input()
        self.output = Output(headerList: self.sortedColums)
        self.coinListService = coinListService
        
        self.inputBinding(self.input)
        self.outputBinding(self.output)
        
        Observable.combineLatest(
            self.input.selectedCoinListType,
            self.input.selectedChangeRatePeriod)
            .flatMap { coinListService.fetchCoinList($0, $1) }
            .map { [SectionModel.init(model: 0, items: $0)] }
            .bind(to: self.output.coinList)
            .disposed(by: self.disposeBag)
    }
    
    func inputBinding(_ event: Input) {
        event.selectedChangeRatePeriod
            .bind(onNext: { period in
                // 이렇게 바로 바인딩 하지 않고 Service 단에 들어갔다가 output에서 나오도록 구현
                self.output.currentChangeRatePeriod.accept(period)
            })
            .disposed(by: self.disposeBag)
        
        event.searchButtonClicked
            .withLatestFrom(event.inputQuery)
            .bind(onNext: { query in
                // 검색 쿼리 서버로 연동
                print(query)
            })
            .disposed(by: self.disposeBag)
        
        event.selectedCoinListType
            .bind(onNext: { coinListType in
                // 쿼리를 날려서 데이터 받아오기
                print(coinListType.rawValue)
            })
            .disposed(by: self.disposeBag)
    }
    
    func outputBinding(_ event: Output) {
        
    }
    
}
