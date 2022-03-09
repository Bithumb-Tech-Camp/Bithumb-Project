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
        let currentSortedColumn = BehaviorRelay<SortedColumn>(value: .init(column: 3, sorting: .descending))
        
        // 이 두 가지 기본 옵션을 UserDefault에서 받아오기
        let currentCoinListType = BehaviorRelay<CoinListType>(value: .popularity)
        let currentChangeRatePeriod = BehaviorRelay<ChangeRatePeriod>(value: .day)
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
        self.inoutBinding()
        
        let httpObservable = httpManager.request(httpServiceType: .ticker("All"), model: [String: TickerString].self)
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
            }})
        
//        Observable.combineLatest(
//            self.output.currentCoinListType.map { $0.query },
//            self.output.currentChangeRatePeriod.map { [$0.rawValue] })
//        map { self.httpManager.request(httpServiceType: .ticker($0), model: [String: TickerString].self)}
        
        httpObservable
            .withLatestFrom(self.output.currentSortedColumn) { ($0, $1) }
            .map { self.sort(coinList: $0, by: $1) }
            .subscribe(onNext: { coinList in
                self.input.coinList.accept(coinList)
            })
            .disposed(by: self.disposeBag)
        
        let tickerParameter: [String: Any] = [
            "type": BithumbWebSocketRequestType.ticker.rawValue,
            "symbols": ["BTC_KRW", "ETH_KRW", "YFI_KRW"], // 모든 값을 가져오거나 내가 관심있는 값을 가져오도록 구현
            "tickTypes": [self.output.currentChangeRatePeriod.value.param]// 모든 값
        ]
        
        webSocketManager.requestRealtime(parameter: tickerParameter, type: RealtimeTicker.self)
            .map { [$0.toDomain()] }
            .withLatestFrom(self.input.coinList) { ($0, $1) }
            .map { self.updateCoinList($1, $0) }
            .bind(to: self.input.coinList)
            .disposed(by: self.disposeBag)
        
    }
    
    func inoutBinding() {
        self.input.selectedChangeRatePeriod
            .bind(onNext: { period in
                self.output.currentChangeRatePeriod.accept(period)
            })
            .disposed(by: self.disposeBag)
        
        self.input.selectedCoinListType
            .bind(onNext: { coinListType in
                self.output.currentCoinListType.accept(coinListType)
            })
            .disposed(by: self.disposeBag)
        
        self.input.selectedSortedColumn
            .bind(to: self.output.currentSortedColumn)
            .disposed(by: self.disposeBag)
        
        self.input.searchButtonClicked
            .withLatestFrom(self.input.inputQuery)
            .bind(onNext: { query in
                // 검색 쿼리 서버로 연동
                print(query)
            })
            .disposed(by: self.disposeBag)
        
        self.input.coinList
            .bind(onNext: { coinList in
                self.output.coinList = coinList
                if let coinListUpdate = self.output.coinListUpdate {
                    coinListUpdate()
                }
            })
            .disposed(by: self.disposeBag)
        
        self.output.currentSortedColumn
            .withLatestFrom(self.input.coinList) { ($0, $1) }
            .map { self.sort(coinList: $1, by: $0) }
            .bind(to: self.input.coinList)
            .disposed(by: self.disposeBag)
    }
    
    func updateCoinList(_ previousList: [Coin], _ afterList: [Coin]) -> [Coin] {
        var previous = previousList
        afterList.forEach { realtime in
            if let index = previous.firstIndex(where: { coin in
                coin.isHigher = nil
                return coin == realtime
            }) {
                let isHigher = realtime > previous[index] ? true : false
                previous.remove(at: index)
                previous.insert(realtime, at: index)
                previous[index].isHigher = isHigher
            }
        }
        return previous
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
