//
//  SocketManager.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/02/25.
//  Updated by Davy on 2022/03/02.

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

final class WebSocketManager: WebSocketService {
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    // swiftlint:disable all
    func requestRealtime<T: Codable>(
        parameter: [String: Any],
        type: T.Type
    ) -> Observable<T> {
        Observable.create {[weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            print(parameter)
            self.response
                .subscribe(onNext: { event in
                    switch event {
                    case .connected:
                        do {
                            let data = try JSONSerialization.data(withJSONObject: parameter, options: [])
                            self.webSocket?.write(data: data)
                        } catch {
                            observer.onError(NetworkError.unknown)
                        }
                    case .text(let string):
                        do {
                            if let data = string.data(using: .utf8) {
                                let json = try JSONDecoder().decode(WebSocketResponse<T>.self, from: data)
                                if let status = json.status {
                                    if status != "0000" {
                                        observer.onError(NetworkError.unknown)
                                    }
                                } else {
                                    if let content = json.content {
                                        observer.onNext(content)
                                    } else {
                                        observer.onError(NetworkError.unknown)
                                    }
                                }
                            }
                        } catch {
                            observer.onError(NetworkError.jsonError)
                        }
                    case .error(let error):
                        if let error = error {
                            observer.onError(error)
                        }
                    default:
                        break
                    }
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    // swiftlint:enable all
}
