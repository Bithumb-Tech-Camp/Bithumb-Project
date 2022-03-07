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
        // 이 세가지 기본 옵션을 UserDefault에서 받아오기
        let selectedSortedColumn = BehaviorRelay<SortedColumn>(value: .init(column: 0, sorting: .ascending))
        let selectedCoinListType = BehaviorRelay<CoinListType>(value: .KRW)
        let selectedChangeRatePeriod = BehaviorRelay<ChangeRatePeriod>(value: .MID)
    }
    
    struct Output {
        var update: (() -> Void)?
        let headerList: [SortedColumn]
        var coinList = [Coin]()
        let requestList = BehaviorRelay<[CoinListType]>(value: CoinListType.allCases)
        let changeRatePeriodList = BehaviorRelay<[ChangeRatePeriod]>(value: ChangeRatePeriod.allCases)
        let currentChangeRatePeriod = BehaviorRelay<ChangeRatePeriod>(value: .MID)
    }
    
    var input: Input
    var output: Output
    var disposeBag = DisposeBag()
    let coinListService: CoinListService
    
    private let sortedColums: [SortedColumn] = (0...4).map { .init(column: $0) }
    
    init(coinListService: CoinListService) {
        self.input = Input()
        self.output = Output(headerList: self.sortedColums)
        self.coinListService = coinListService
        
        self.inputBinding(self.input)
        self.outputBinding(self.output)
        
        Observable.combineLatest(
            self.input.selectedCoinListType,
            self.input.selectedChangeRatePeriod,
            self.input.selectedSortedColumn)
            .flatMap { [weak self] type, period, standard -> Observable<[Coin]> in
                guard let self = self else {
                    return .empty()
                }
                return self.coinListService.fetchCoinList(type, period)
                    .map { self.sort(coinList: $0, by: standard) }
            }
            .bind(onNext: { [weak self] coinList in
                self?.output.coinList = coinList
                if let update = self?.output.update {
                    update()
                }
            })
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
//                print(coinListType.rawValue)
            })
            .disposed(by: self.disposeBag)
    }
    
    func outputBinding(_ event: Output) {
        
    }
    
    func sort(coinList: [Coin], by standard: SortedColumn) -> [Coin] {
        switch standard {
        case .init(column: 0, sorting: .ascending):
            return coinList.sorted { $0.krName < $1.krName }
        case .init(column: 0, sorting: .descending):
            return coinList.sorted { $0.krName > $1.krName }
        case .init(column: 1, sorting: .ascending):
            return coinList.sorted { $0.ticker < $1.ticker }
        case .init(column: 1, sorting: .descending):
            return coinList.sorted { $0.ticker > $1.ticker }
        case .init(column: 2, sorting: .ascending):
            return coinList.sorted { $0.changeRate.rate < $1.changeRate.rate }
        case .init(column: 2, sorting: .descending):
            return coinList.sorted { $0.changeRate.rate > $1.changeRate.rate }
        case .init(column: 3, sorting: .ascending):
            return coinList.sorted { $0.transaction < $1.transaction }
        case .init(column: 3, sorting: .descending):
            return coinList.sorted { $0.transaction > $1.transaction }
        default:
            return []
        }
    }
    
}
