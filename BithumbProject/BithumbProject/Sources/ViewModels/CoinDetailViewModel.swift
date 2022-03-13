//
//  CoinDetailViewModel.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/02.
//

import Foundation

import RxSwift
import RxRelay

final class CoinDetailViewModel: ViewModelType {
    
    struct Input {
        let fetchTicker: PublishSubject<Void> = PublishSubject<Void>()
        let fetchRealtimeTicker: PublishSubject<Void> = PublishSubject<Void>()
    }
    
    struct Output {
        let closePriceText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        let changeAmountText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        let changeRateText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        let upDown: BehaviorRelay<UpDown> = BehaviorRelay<UpDown>(value: .up)
        let realtimeClosePriceText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        let realtimeChangeAmountText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        let realtimeChangeRateText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        let realtimeUpDown: BehaviorRelay<UpDown> = BehaviorRelay<UpDown>(value: .up)
        let error: PublishRelay<NSError> = PublishRelay<NSError>()
    }
    
    let input: Input
    let output: Output
    var coin: Coin
    var httpManager: HTTPManager
    var webSockerManager: WebSocketManager
    var disposeBag: DisposeBag = DisposeBag()
    
    init(coin: Coin, httpManager: HTTPManager, webSocketManager: WebSocketManager) {
        self.input = Input()
        self.output = Output()
        self.coin = coin
        self.httpManager = httpManager
        self.webSockerManager = webSocketManager
        
        input.fetchTicker
            .flatMap { _ -> Observable<Ticker> in
                httpManager.request(httpServiceType: .ticker(coin.orderCurrency), model: Ticker.self)
            }
            .subscribe(onNext: {[weak self] ticker in
                guard let self = self else { return }
                let changeAmountSign = Double(ticker.fluctate24H ?? "0") ?? 0 >= 0 ? "+" : ""
                let changeRateSign = Double(ticker.fluctateRate24H ?? "0") ?? 0 >= 0 ? "▲" : "▼"
                let upDown: UpDown = Double(ticker.fluctate24H ?? "0") ?? 0 >= 0 ? .up : .down
                
                self.output.closePriceText.accept(Double(ticker.closingPrice ?? "0")?.decimal ?? "0")
                self.output.changeAmountText.accept("\(changeAmountSign)\(Double(ticker.fluctate24H ?? "0")?.decimal ?? "0")")
                self.output.changeRateText.accept("\(changeRateSign)\(Double(ticker.fluctateRate24H ?? "0") ?? 0)%")
                self.output.upDown.accept(upDown)
                
            }, onError: { error in
                self.output.error.accept(error as NSError)
            })
            .disposed(by: disposeBag)
        
        input.fetchRealtimeTicker
            .flatMap { _ -> Observable<RealtimeTicker> in
                let parameter: [String: Any] = [
                    "type": BithumbWebSocketRequestType.ticker.rawValue,
                    "symbols": [coin.orderCurrency],
                    "tickTypes": [RealtimeTickType.twentyFourHour].map { $0.rawValue }
                ]
                return webSocketManager.requestRealtime(parameter: parameter, type: RealtimeTicker.self)
            }
            .filter { !$0.isEmpty }
            .subscribe(onNext: {[weak self] realtimeTicker in
                guard let self = self else { return }
                let changeAmountSign = Double(realtimeTicker.changeAmount ?? "0") ?? 0 >= 0 ? "+" : ""
                let changeRateSign = Double(realtimeTicker.changeRate ?? "0") ?? 0 >= 0 ? "▲" : "▼"
                let upDown: UpDown = Double(realtimeTicker.changeAmount ?? "0") ?? 0 >= 0 ? .up : .down
                
                self.output.realtimeClosePriceText.accept(Double(realtimeTicker.closePrice ?? "0")?.decimal ?? "0")
                self.output.realtimeChangeAmountText.accept("\(changeAmountSign)\(Double(realtimeTicker.changeAmount ?? "0")?.decimal ?? "0")")
                self.output.realtimeChangeRateText.accept("\(changeRateSign)\(Double(realtimeTicker.changeRate ?? "0") ?? 0)%")
                self.output.realtimeUpDown.accept(upDown)
                
            }, onError: {[weak self] error in
                guard let self = self else { return }
                self.output.error.accept(error as NSError)
            })
            .disposed(by: disposeBag)
    }
}
