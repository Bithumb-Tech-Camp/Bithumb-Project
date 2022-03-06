//
//  TransactionViewModel.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/03/06.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

final class TransactionViewModel: ViewModelType {
    var input: Input
    var output: Output
    var disposeBag: DisposeBag = DisposeBag()

    struct Input {
        let transactionData = PublishRelay<[TransactionHistory]>()
        let realtimeTransationData = PublishRelay<RealtimeTransaction>()
    }
    
    struct Output {
        let transactionData = BehaviorRelay<[TransactionHistory]>(value: [])
        let realtimeTransationData = BehaviorRelay<RealtimeTransaction>(value: RealtimeTransaction())
    }
    
    init() {
        self.input = Input()
        self.output = Output()
        
        let provider = MoyaProvider<HTTPService>()
        let httpManager = HTTPManager(provider: provider)
        let webSocketManager = WebSocketManager()
        
        let transactionParameter: [String: Any] = [
               "type": BithumbWebSocketRequestType.transaction.rawValue,
               "symbols": ["BTC_KRW"]
            ]

        httpManager.request(httpServiceType: .transactionHistory("BTC"), model: [TransactionHistory].self)
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
            .bind(to: input.transactionData)
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
}
