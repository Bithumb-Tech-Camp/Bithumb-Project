//
//  OrderBookViewModel.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/26.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import RxOptional

final class OrderBookViewModel: ViewModelType {
    
    struct Input {
        let orderBookData = PublishRelay<OrderBook>()
        let bidList = PublishRelay<[BidAsk]>()
        let askList = PublishRelay<[BidAsk]>()
        let realtimeOrderBookData = PublishRelay<RealtimeOrderBook>()
        let tickerData = PublishRelay<Ticker>()
        let prevClosingPrice = PublishRelay<String>()
        let closePrice = PublishRelay<String>()
    }
    
    struct Output {
        let orderBookData = BehaviorRelay<OrderBook>(value: OrderBook())
        let bidList = BehaviorRelay<[BidAsk]>(value: [])
        let askList = BehaviorRelay<[BidAsk]>(value: [])
        let realtimeOrderBookData = BehaviorRelay<RealtimeOrderBook>(value: RealtimeOrderBook())
        let tickerData = BehaviorRelay<Ticker>(value: Ticker())
        let prevClosingPrice = BehaviorRelay<String>(value: "")
        let closePrice = BehaviorRelay<String>(value: "")
    }
    
    var input: Input
    var output: Output
    var disposeBag: DisposeBag = DisposeBag()
    var coin: Coin
    
    init(coin: Coin, httpManager: HTTPManager, webSocketManager: WebSocketManager) {
        self.input = Input()
        self.output = Output()
        self.coin = coin
        
        let orderBookParameter: [String: Any] = [
              "type": BithumbWebSocketRequestType.orderBookDepth.rawValue,
              "symbols": [coin.acronyms]
            ]
        
        let tickerParameter: [String: Any] = [
              "type": BithumbWebSocketRequestType.ticker.rawValue,
              "symbols": [coin.acronyms],
              "tickTypes": [RealtimeTickType.twentyFourHour].map { $0.rawValue }
             ]
        
        webSocketManager.requestRealtime(parameter: tickerParameter, type: RealtimeTicker.self)
            .map { $0.closePrice }
            .filterNil()
            .bind(to: input.closePrice)
            .disposed(by: disposeBag)
        
        input.closePrice
            .bind(to: output.closePrice)
            .disposed(by: disposeBag)
        
        httpManager.request(httpServiceType: .ticker(coin.acronyms), model: Ticker.self)
            .bind(to: input.tickerData)
            .disposed(by: disposeBag)
        
        input.tickerData
            .bind(to: output.tickerData)
            .disposed(by: disposeBag)
        
        input.tickerData
            .map { $0.prevClosingPrice }
            .filterNil()
            .bind(to: input.prevClosingPrice)
            .disposed(by: disposeBag)
        
        input.prevClosingPrice
            .bind(to: output.prevClosingPrice)
            .disposed(by: disposeBag)
        
        httpManager.request(httpServiceType: .orderBook(coin.acronyms), model: OrderBook.self)
            .bind(to: input.orderBookData)
            .disposed(by: disposeBag)
        
        input.orderBookData
            .bind(to: output.orderBookData)
            .disposed(by: disposeBag)
        
        output.orderBookData
            .map { $0.bids ?? [] }
            .map { $0.sorted { $0.price ?? "" > $1.price ?? "" } }
            .bind(to: input.bidList)
            .disposed(by: disposeBag)
        
        input.bidList
            .bind(to: output.bidList)
            .disposed(by: disposeBag)
        
        output.orderBookData
            .map { $0.asks ?? [] }
            .map { $0.sorted { $0.price ?? "" > $1.price ?? "" } }
            .bind(to: input.askList)
            .disposed(by: disposeBag)
        
        input.askList
            .bind(to: output.askList)
            .disposed(by: disposeBag)

        webSocketManager.requestRealtime(parameter: orderBookParameter, type: RealtimeOrderBook.self)
            .bind(to: input.realtimeOrderBookData)
            .disposed(by: disposeBag)
        
        input.realtimeOrderBookData
            .bind(to: output.realtimeOrderBookData)
            .disposed(by: disposeBag)
        
        output.realtimeOrderBookData
            .map { $0.list?.filter { $0.orderType == "bid" } }
            .withLatestFrom(output.bidList) {( $0, $1 )}
            .map { self.reflectRealtimeData(previousList: $0.1, realtimeList: $0.0.value ?? [] ) }
            .map { $0.sorted { $0.price ?? "" > $1.price ?? "" }}
            .bind(to: input.bidList)
            .disposed(by: disposeBag)
        
        output.realtimeOrderBookData
            .map { $0.list?.filter { $0.orderType == "ask" } }
            .withLatestFrom(output.askList) {( $0, $1 )}
            .map { self.reflectRealtimeData(previousList: $0.1, realtimeList: $0.0.value ?? [] ) }
            .map { $0.sorted { $0.price ?? "" > $1.price ?? "" }}
            .bind(to: input.askList)
            .disposed(by: disposeBag)
    }
    
    private func reflectRealtimeData(previousList: [BidAsk], realtimeList: [RealtimeOrderbookDepth]) -> [BidAsk] {
        var changedList = previousList
        realtimeList.forEach { realtimeItem in
            if let index = changedList.firstIndex(where: { $0.price == realtimeItem.price }) {
                if realtimeItem.quantity == "0" {
                    changedList.remove(at: index)
                } else {
                    changedList[index].price = realtimeItem.price
                    changedList[index].quantity = realtimeItem.quantity
                }
            } else {
                changedList.append(BidAsk(quantity: realtimeItem.quantity, price: realtimeItem.price))
            }
        }
        return changedList
    }
}
