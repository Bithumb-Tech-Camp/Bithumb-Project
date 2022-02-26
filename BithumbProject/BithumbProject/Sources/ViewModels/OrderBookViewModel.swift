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

final class OrderBookViewModel: ViewModelType {

    var input: Input
    var output: Output
    var disposeBag: DisposeBag = DisposeBag()

    struct Input {
        let orderBookData = PublishRelay<OrderBook>()
        let bidList = PublishRelay<[BidAsk]>()
        let askList = PublishRelay<[BidAsk]>()
        let realtimeOrderBookData = PublishRelay<RealtimeOrderBook>()
    }
    
    struct Output {
        let orderBookData = BehaviorRelay<OrderBook>(value: OrderBook())
        let bidList = BehaviorRelay<[BidAsk]>(value: [])
        let askList = BehaviorRelay<[BidAsk]>(value: [])
        let realtimeOrderBookData = BehaviorRelay<RealtimeOrderBook>(value: RealtimeOrderBook())
    }
    
    init() {
        self.input = Input()
        self.output = Output()
        
        let provider = MoyaProvider<HTTPService>()
        let httpManager = HTTPManager(provider: provider)
        let webSocketManager = WebSocketManager()
        
        input.orderBookData
            .bind(to: output.orderBookData)
            .disposed(by: disposeBag)
        
        input.bidList
            .bind(to: output.bidList)
            .disposed(by: disposeBag)
        
        input.askList
            .bind(to: output.askList)
            .disposed(by: disposeBag)
        
        input.realtimeOrderBookData
            .bind(to: output.realtimeOrderBookData)
            .disposed(by: disposeBag)
        
        httpManager.request(httpServiceType: .orderBook("BTC"), model: OrderBook.self)
            .bind(to: input.orderBookData)
            .disposed(by: disposeBag)
        
        output.orderBookData
            .map { $0.bids ?? [] }
            .map { $0.sorted { $0.price ?? "" > $1.price ?? "" } }
            .bind(to: input.bidList)
            .disposed(by: disposeBag)
        
        output.orderBookData
            .map { $0.asks ?? [] }
            .map { $0.sorted { $0.price ?? "" > $1.price ?? "" } }
            .bind(to: input.askList)
            .disposed(by: disposeBag)
        
        webSocketManager.requestRealtimeOrderbook()
            .bind(to: input.realtimeOrderBookData)
            .disposed(by: disposeBag)
        
        output.realtimeOrderBookData
            .map { $0.list?.filter { $0.orderType == "bid" } ?? [] }
            .withUnretained(output.bidList) {( $0, $1 )}
            .map { self.reflectRealtimeData(previousList: $0.value, realtimeList: $1) }
            .map { $0.sorted { $0.price ?? "" > $1.price ?? "" }}
            .bind(to: input.bidList)
            .disposed(by: disposeBag)
        
        output.realtimeOrderBookData
            .map { $0.list?.filter { $0.orderType == "ask" } ?? [] }
            .withUnretained(output.askList) {( $0, $1 )}
            .map { self.reflectRealtimeData(previousList: $0.value, realtimeList: $1) }
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
