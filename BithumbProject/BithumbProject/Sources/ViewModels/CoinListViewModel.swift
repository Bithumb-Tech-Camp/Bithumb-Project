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
        let currentSortedColumn = BehaviorRelay<SortedColumn>(value: .init(column: 1))
        
        // 이 두 가지 기본 옵션을 UserDefault에서 받아오기
        let currentCoinListType = BehaviorRelay<CoinListType>(value: .KRW)
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
        self.connectionToManager()
    }
    
    func connectionToManager() {
        // HTTP는 ChangeRatePeriod에 대한 24H 값만 제공, 해당 데이터만 요청 받을 수 있음
        // 변동률 기간에서는 처음 데이터를 불러오는 것 이외의 데이터 요청은 의미가 없다.
        // 그래도 반응은 하게 만들었
        Observable.combineLatest(
            self.output.currentChangeRatePeriod,
            self.output.currentCoinListType,
            resultSelector: { $1 })
            .flatMap { self.fetchCoinList($0) }
            .withLatestFrom(self.output.currentSortedColumn) { ($0, $1) }
            .map { self.sort(coinList: $0, by: $1) }
            .subscribe(onNext: { coinList in
                self.input.coinList.accept(coinList)
            })
            .disposed(by: self.disposeBag)
        
        // WebSocket 데이터는 반대로 기간에만 영향을 받도록 구현
        // 인기, 검색 내역, 관심, 원화 모두에 영향을 미치기 때문
        self.output.currentChangeRatePeriod
            .map { self.makeWebSocketParameters($0) }
            .flatMap {  self.webSocketManager.requestRealtime(parameter: $0, type: RealtimeTicker.self) }
            .filter { $0.closePrice != nil }
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
            .compactMap { "\($0.uppercased())_KRW" }
            .flatMap { self.httpManager.request(httpServiceType: .ticker($0), model: Ticker.self) }
            .map { [$0.toDomain()] }
            .subscribe(onNext: { coinlist in
                self.input.coinList.accept(coinlist)
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
    
    func fetchCoinList(_ coinListType: CoinListType) -> Observable<[Coin]> {
        switch coinListType {
        case .KRW:
            return self.httpManager.request(
                httpServiceType: .ticker(coinListType.param),
                model: [String: TickerString].self)
                .map { $0.compactMap { acronyms, tickerString -> Coin? in
                    guard let coin = tickerString.toDomain() else {
                        return nil
                    }
                    coin.krName = "\(acronyms)코인"
                    coin.acronyms = acronyms
                    return coin
                }}
        case .popularity:
            return self.httpManager.request(
                httpServiceType: .ticker(coinListType.param),
                model: [String: TickerString].self)
                .map { $0.compactMap { acronyms, tickerString -> Coin? in
                    guard let coin = tickerString.toDomain() else {
                        return nil
                    }
                    coin.krName = "\(acronyms)코인"
                    coin.acronyms = acronyms
                    return coin
                }}
                .do(onNext: { [weak self] _ in
                    self?.input.selectedSortedColumn.accept(.init(column: 3, sorting: .descending))
                })
        case .favorite:
            let favoriteCoinParams = CommonUserDefault<String>.fetch(.star(""))
            return Observable.zip(
                favoriteCoinParams
                    .map { [weak self] param -> Observable<Coin> in
                        guard let self = self else {
                            return .empty()
                        }
                        print(param)
                        return self.httpManager.request(httpServiceType: .ticker(param), model: Ticker.self)
                            .map { ticker in
                                let coin = ticker.toDomain()
                                let acronyms = param.components(separatedBy: "_").first ?? ""
                                coin.krName = "\(acronyms)코인"
                                coin.acronyms = acronyms
                                return coin
                            }
                    })
        }
    }
    
    func makeWebSocketParameters(_ changeRatePeriod: ChangeRatePeriod) -> [String: Any] {
        let tickerParameter: [String: Any] = [
            "type": BithumbWebSocketRequestType.ticker.rawValue,
            "symbols": Constant.Parameters.coinList,
            "tickTypes": [changeRatePeriod.param]
        ]
        return tickerParameter
    }
    
    func updateCoinList(_ previousList: [Coin], _ afterList: [Coin]) -> [Coin] {
        var previous = previousList
        afterList.forEach { realtime in
            if let index = previous.firstIndex(where: { coin in
                coin.isHigher = nil
                return coin == realtime
            }) {
                let isHigher = realtime > previous[index]
                
                realtime.isHigher = isHigher
                previous.remove(at: index)
                previous.insert(realtime, at: index)
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
