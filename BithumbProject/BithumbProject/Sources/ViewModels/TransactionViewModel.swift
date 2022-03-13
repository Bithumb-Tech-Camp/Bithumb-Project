//
//  TransactionCellViewModel.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/03/04.
//

import Foundation
import RxSwift
import RxRelay
import Moya

final class TransactionViewModel: ViewModelType {
    
    struct Input {
        let transactionData = PublishRelay<[TransactionHistory]>()
        let realtimeTransationData = PublishRelay<RealtimeTransaction>()
        let volumePower = PublishRelay<String>()
    }
    
    struct Output {
        let transactionData = BehaviorRelay<[TransactionHistory]>(value: [])
        let realtimeTransationData = BehaviorRelay<RealtimeTransaction>(value: RealtimeTransaction())
        let volumePower = BehaviorRelay<String>(value: "")
    }
    
    var input: Input
    var output: Output
    var coin: Coin
    var disposeBag: DisposeBag = DisposeBag()
    
    init(coin: Coin, httpManager: HTTPManager, webSocketManager: WebSocketManager) {
        self.input = Input()
        self.output = Output()
        self.coin = coin
        
        let transactionParameter: [String: Any] = [
               "type": BithumbWebSocketRequestType.transaction.rawValue,
               "symbols": [coin.orderCurrency]
            ]
        
        let tickerParameter: [String: Any] = [
              "type": BithumbWebSocketRequestType.ticker.rawValue,
              "symbols": [coin.acronyms],
              "tickTypes": [RealtimeTickType.twentyFourHour].map { $0.rawValue }
             ]

        httpManager.request(httpServiceType: .transactionHistory(coin.orderCurrency), model: [TransactionHistory].self)
            .map { self.addUpdownColumn($0) }
            .bind(to: input.transactionData)
            .disposed(by: disposeBag)
        
        input.transactionData
            .bind(to: output.transactionData)
            .disposed(by: disposeBag)
        
        webSocketManager.requestRealtime(parameter: transactionParameter, type: RealtimeTransaction.self)
            .bind(to: input.realtimeTransationData)
            .disposed(by: disposeBag)
        
        input.realtimeTransationData
            .withLatestFrom(input.transactionData) {( $0, $1 )}
            .map { self.updateTransationData(realtimeList: $0.0.list, previousList: $0.1) }
            .map { $0.sorted { $0.date > $1.date }}
            .map { Array($0.prefix(40)) }
            .bind(to: input.transactionData)
            .disposed(by: disposeBag)
        
        webSocketManager.requestRealtime(parameter: tickerParameter, type: RealtimeTicker.self)
            .map { $0.volumePower }
            .filterNil()
            .bind(to: input.volumePower)
            .disposed(by: disposeBag)
        
        input.volumePower
            .bind(to: output.volumePower)
            .disposed(by: disposeBag)
    }
    
    private func updateTransationData(realtimeList: [RealtimeTransactionItem]?, previousList: [TransactionHistory]) -> [TransactionHistory] {
        var updatedList = previousList
        realtimeList?.forEach {
            var transaction = TransactionHistory()
            transaction.price = $0.contractPrice
            transaction.unitsTraded = $0.contractQuantity
            transaction.updown = $0.updown
            transaction.transactionDate = $0.contractDatetime?.changeDateFormat(from: "YYYY-MM-DD HH:mm:ss.SSS", to: "YYYY-MM-DD HH:mm:ss")
            updatedList.append(transaction)
        }
        return updatedList
    }
    
    private func addUpdownColumn(_ transationData: [TransactionHistory]) -> [TransactionHistory] {
        var updatedList = transationData
        for i in 1..<updatedList.count {
            updatedList[i].updown = updatedList[i-1].price ?? "" <= updatedList[i].price ?? "" ? "up" : "dn"
        }
        return updatedList
    }
}
