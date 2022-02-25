//
//  TickerService.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/02/24.
//

import Foundation

import RxSwift
import Starscream

protocol WebSocketServiceType {
    var response: Observable<WebSocketEvent> { get }
    func connect()
    func disconnect()
}

class WebSocketService: WebSocketServiceType {
    
    var webSocket: WebSocket?
    private let subject = PublishSubject<WebSocketEvent>()
    var response: Observable<WebSocketEvent> {
        return subject.asObservable()
    }
    
    init(url: String = Const.URL.webSocketBaseURL) {
        guard let url = URL(string: url) else {
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        self.webSocket = WebSocket(request: request)
        self.webSocket?.delegate = self
        self.connect()
    }
    
    func connect() {
        self.webSocket?.connect()
    }
    
    func disconnect() {
        self.webSocket?.disconnect()
    }
    
    deinit {
        self.subject.onCompleted()
        self.disconnect()
    }
}

extension WebSocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            subject.onNext(WebSocketEvent.connected(headers))
        case .disconnected(let reason, let code):
            subject.onNext(WebSocketEvent.disconnected(reason, code))
        case .text(let string):
            subject.onNext(WebSocketEvent.text(string))
        case .binary(let data):
            subject.onNext(WebSocketEvent.binary(data))
        case .pong(_):
            return
        case .ping(_):
            return
        case .error(let error):
            subject.onNext(WebSocketEvent.error(error))
        case .viabilityChanged(_):
            return
        case .reconnectSuggested(_):
            return
        case .cancelled:
            return
        }
    }
}
