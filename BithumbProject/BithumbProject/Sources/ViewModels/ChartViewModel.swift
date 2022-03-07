//
//  ChartViewModel.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/04.
//

import Foundation

import RxSwift
import RxRelay

final class ChartViewModel: ViewModelType {
    
    struct Input {
        let fetchCandlestick: PublishSubject<Void> = PublishSubject<Void>()
        let fetchRealtimeTicker: PublishSubject<Void> = PublishSubject<Void>()
        var changeOption: BehaviorSubject<ChartOption> = BehaviorSubject<ChartOption>(
            value: ChartOption(orderCurrency: Coin(name: "BTC").symbol, interval: .day, layout: .single)
        )
    }
    
    struct Output {
        let candlesticks: PublishRelay<[Candlestick]> = PublishRelay<[Candlestick]>()
        let realtimeTicker: PublishRelay<RealtimeTicker> = PublishRelay<RealtimeTicker>()
        var option: BehaviorRelay<ChartOption> = BehaviorRelay<ChartOption>(
            value: ChartOption(orderCurrency: Coin(name: "BTC").symbol, interval: .day, layout: .single)
        )
        let error: PublishRelay<NSError> = PublishRelay<NSError>()
    }
    
    var input: Input
    var output: Output
    var disposeBag: DisposeBag = DisposeBag()
    
    init(orderCurrency: OrderCurrency, httpManager: HTTPManager, webSocketManager: WebSocketManager) {
        self.input = Input()
        self.output = Output()
        
        input.changeOption = BehaviorSubject<ChartOption>(
            value: ChartOption(orderCurrency: orderCurrency, interval: .day, layout: .single)
        )
        output.option = BehaviorRelay<ChartOption>(
            value: ChartOption(orderCurrency: orderCurrency, interval: .day, layout: .single)
        )
        
        Observable.combineLatest(input.fetchCandlestick, input.changeOption)
            .distinctUntilChanged({ old, new in
                old.1 == new.1
            })
            .flatMap { _, option -> Observable<[[IntOrString]]> in
                httpManager.request(
                    httpServiceType: .candleStick(option.orderCurrency, option.interval.toAPI),
                    model: [[IntOrString]].self
                )
            }
            .map {
                $0.map { array -> Candlestick in
                    Candlestick(array: array)
                }
            }
            .subscribe(onNext: { candlesticks in
                self.output.candlesticks.accept(candlesticks)
            }, onError: { error in
                self.output.error.accept(error as NSError)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.fetchRealtimeTicker, input.changeOption)
            .flatMap { _, option -> Observable<RealtimeTicker> in
                let parameter: [String: Any] = [
                    "type": BithumbWebSocketRequestType.ticker.rawValue,
                    "symbols": [option.orderCurrency],
                    "tickTypes": [TickType.thirtyMinute].map { $0.rawValue }
                ]
                return webSocketManager.requestRealtime(parameter: parameter, type: RealtimeTicker.self)
            }
            .subscribe(onNext: { realtimeTicker in
                self.output.realtimeTicker.accept(realtimeTicker)
            }, onError: { error in
                self.output.error.accept(error as NSError)
            })
            .disposed(by: disposeBag)
        
        input.changeOption
            .subscribe(onNext: { option in
                self.output.option.accept(option)
            })
            .disposed(by: disposeBag)
    }
}
