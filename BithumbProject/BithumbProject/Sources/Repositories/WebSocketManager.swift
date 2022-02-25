//
//  SocketManager.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/02/25.
//

import Foundation

import RxSwift
import RxCocoa

enum BithumbWebSocketRequestType: String {
    case ticker
    case transaction
    case orderBookDepth = "orderbookdepth"
}

enum TickType: String {
    case thirtyMinute = "30M"
    case oneHour = "1H"
    case twelveHour = "12H"
    case twentyFourHour = "24H"
    case mid = "MID"
}

final class WebSocketManager: BithumbWebSocketService {
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    func requestRealtimeTicker(
        symbols: [String] = ["BTC_KRW"],
        tickTypes: [TickType]
    ) -> Observable<RealtimeTicker> {
        Observable.create {[weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            let json: [String: Any] = [
                "type": BithumbWebSocketRequestType.ticker.rawValue,
                "symbols": symbols,
                "tickTypes": tickTypes.map { $0.rawValue }
            ]
            self.response
                .subscribe(onNext: { event in
                    switch event {
                    case .connected(_):
                        do {
                            let data = try JSONSerialization.data(withJSONObject: json, options: [])
                            self.webSocket?.write(data: data)
                        } catch {
                            observer.onError(NetworkError.unknown)
                        }
                    case .text(let string):
                        do {
                            if let data = string.data(using: .utf8) {
                                let json = try JSONDecoder().decode(WebSocketResponse<RealtimeTicker>.self, from: data)
                                if let content = json.content {
                                    observer.onNext(content)
                                } else {
                                    observer.onError(NetworkError.unknown)
                                }
                            }
                        } catch {
                            observer.onError(NetworkError.jsonError)
                        }
                    case .error(let error):
                        if let error = error {
                            observer.onError(error)
                        }
                    case .disconnected(_, _),
                        .binary(_),
                        .pong(_),
                        .ping(_),
                        .viabilityChanged(_),
                        .reconnectSuggested(_),
                        .cancelled:
                        return
                    }
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func requestRealtimeOrderbook(
        symbols: [String] = ["BTC_KRW"]
    ) -> Observable<RealtimeOrderBook> {
        Observable.create {[weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            let json: [String: Any] = [
                "type": BithumbWebSocketRequestType.orderBookDepth.rawValue,
                "symbols": symbols
            ]
            self.response
                .subscribe(onNext: { event in
                    switch event {
                    case .connected(_):
                        do {
                            let data = try JSONSerialization.data(withJSONObject: json, options: [])
                            self.webSocket?.write(data: data)
                        } catch {
                            observer.onError(NetworkError.unknown)
                        }
                    case .text(let string):
                        do {
                            if let data = string.data(using: .utf8) {
                                let json = try JSONDecoder().decode(WebSocketResponse<RealtimeOrderBook>.self, from: data)
                                if let content = json.content {
                                    observer.onNext(content)
                                } else {
                                    observer.onError(NetworkError.unknown)
                                }
                            }
                        } catch {
                            observer.onError(NetworkError.jsonError)
                        }
                    case .error(let error):
                        if let error = error {
                            observer.onError(error)
                        }
                    case .disconnected(_, _),
                        .binary(_),
                        .pong(_),
                        .ping(_),
                        .viabilityChanged(_),
                        .reconnectSuggested(_),
                        .cancelled:
                        return
                    }
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func requestRealtimeTransaction(
        symbols: [String] = ["BTC_KRW"]
    ) -> Observable<RealtimeTransaction> {
        Observable.create {[weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            let json: [String: Any] = [
                "type": BithumbWebSocketRequestType.transaction.rawValue,
                "symbols": symbols
            ]
            self.response
                .subscribe(onNext: { event in
                    switch event {
                    case .connected(_):
                        do {
                            let data = try JSONSerialization.data(withJSONObject: json, options: [])
                            self.webSocket?.write(data: data)
                        } catch {
                            observer.onError(NetworkError.unknown)
                        }
                    case .text(let string):
                        do {
                            print(string)
                            if let data = string.data(using: .utf8) {
                                let json = try JSONDecoder().decode(WebSocketResponse<RealtimeTransaction>.self, from: data)
                                if let content = json.content {
                                    observer.onNext(content)
                                } else {
                                    observer.onError(NetworkError.unknown)
                                }
                            }
                        } catch {
                            observer.onError(NetworkError.jsonError)
                        }
                    case .error(let error):
                        if let error = error {
                            observer.onError(error)
                        }
                    case .disconnected(_, _),
                        .binary(_),
                        .pong(_),
                        .ping(_),
                        .viabilityChanged(_),
                        .reconnectSuggested(_),
                        .cancelled:
                        return
                    }
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
}
