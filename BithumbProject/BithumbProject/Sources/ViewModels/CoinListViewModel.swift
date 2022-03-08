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
        let coinList = PublishRelay<[Coin]>()
        
        let selectedSortedColumn = PublishRelay<SortedColumn>()
        let selectedCoinListType = PublishRelay<CoinListType>()
        let selectedChangeRatePeriod = PublishRelay<ChangeRatePeriod>()
    }
    
    struct Output {
        var coinListUpdate: (() -> Void)?
        var coinList = [Coin]()
        let currentSortedColumn = BehaviorRelay<SortedColumn>(value: .init(column: 1, sorting: .descending))
        
        // 이 두 가지 기본 옵션을 UserDefault에서 받아오기
        let currentCoinListType = BehaviorRelay<CoinListType>(value: .popularity)
        let currentChangeRatePeriod = BehaviorRelay<ChangeRatePeriod>(value: .hour)
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
        
        self.inoutBinding(self.input, self.output)
        
        httpManager.request(httpServiceType: .ticker("All"), model: [String: TickerString].self)
            .map({ $0.compactMap { acronyms, ticker -> Coin? in
                    switch ticker {
                    case .string:
                        return nil
                    case .ticker(let newTicker):
                        let coin = newTicker.toDomain()
                        coin.krName = "\(acronyms)코인"
                        coin.acronyms = acronyms
                        return coin
                    }
                }
            })
            .withLatestFrom(self.output.currentSortedColumn) { ($0, $1) }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                onNext: { coinList, sorted in
                    let sortedCoinList = self.sort(coinList: coinList, by: sorted)
                    self.input.coinList.accept(sortedCoinList)
                },
                onError: { error in
                    print("error!1 \(error)")
                })
            .disposed(by: self.disposeBag)
        
//        let tickerParameter: [String: Any] = [
//            "type": BithumbWebSocketRequestType.ticker.rawValue,
//            "symbols": ["BTC_KRW"],
//            "tickTypes": [self.output.currentChangeRatePeriod.value.param]
//        ]
//
//        webSocketManager.requestRealtime(parameter: tickerParameter, type: RealtimeTicker.self)
//            .map { [$0.toDomain()] }
//            .subscribe(
//                onNext: { coinList in
//                self.input.coinList.accept(coinList)
//                },
//                onError: { error in
//                    print("error!2 \(error)")
//                }
//            )
//            .disposed(by: self.disposeBag)
        
        // 정렬할 때마다 데이터 요청되지 않도록 수정
//        Observable.combineLatest(
//            self.output.currentCoinListType,
//            self.output.currentChangeRatePeriod,
//            self.output.currentSortedColumn)
//            .flatMap { [weak self] type, period, standard -> Observable<[Coin]> in
//                guard let self = self else {
//                    return .empty()
//                }
//                return self.coinListService.fetchCoinList(type, period)
//                    .map { self.sort(coinList: $0, by: standard) }
//            }
//            .withUnretained(self)
//            .bind(onNext: { owner, coinList in
//                owner.output.coinList = coinList
//                if let coinListUpdate = owner.output.coinListUpdate {
//                    coinListUpdate()
//                }
//            })
//            .disposed(by: self.disposeBag)
    }
    
    func inoutBinding(_ event: Input, _ state: Output) {
        event.selectedChangeRatePeriod
            .bind(onNext: { period in
                state.currentChangeRatePeriod.accept(period)
            })
            .disposed(by: self.disposeBag)
        
        event.selectedCoinListType
            .bind(onNext: { coinListType in
                state.currentCoinListType.accept(coinListType)
            })
            .disposed(by: self.disposeBag)
        
        event.selectedSortedColumn
            .bind(onNext: { sortType in
                state.currentSortedColumn.accept(sortType)
            })
            .disposed(by: self.disposeBag)
        
        event.searchButtonClicked
            .withLatestFrom(event.inputQuery)
            .bind(onNext: { query in
                // 검색 쿼리 서버로 연동
                print(query)
            })
            .disposed(by: self.disposeBag)
        
        event.coinList
            .bind(onNext: { coinList in
                self.output.coinList = coinList
                if let coinListUpdate = self.output.coinListUpdate {
                    coinListUpdate()
                }
            })
            .disposed(by: self.disposeBag)
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
