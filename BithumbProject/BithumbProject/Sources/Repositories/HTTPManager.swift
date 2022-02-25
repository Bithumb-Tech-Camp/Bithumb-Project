//
//  HTTPManager.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/24.
//

import Foundation

import Moya
import RxSwift

final class HTTPManager {
    private let provider: MoyaProvider<HTTPService>
    
    init(provider: MoyaProvider<HTTPService>) {
        self.provider = provider
    }
    
    func requestAssetsStatusList() -> Observable<[String:AssetsStatus]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            self.provider.request(.assetsStatus()) { result in
                switch result {
                case .success(let response):
                    do {
                        let assetsStatusList = try JSONDecoder().decode(HTTPResponse<[String:AssetsStatus]>.self, from: response.data)
                        guard let data = assetsStatusList.data else { return }
                        observer.onNext(data)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func requestCoinList() -> Observable<[Coin]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            self.provider.request(.assetsStatus()) { result in
                switch result {
                case .success(let response):
                    do {
                        let httpResponse = try JSONDecoder().decode(HTTPResponse<[String:AssetsStatus]>.self, from: response.data)
                        let coinList = httpResponse.data?.keys.map { Coin(name: $0) } ?? []
                        observer.onNext(coinList)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func requestTicker(_ query: OrderCurrency) -> Observable<Ticker?> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            self.provider.request(.ticker(query)) { result in
                switch result {
                case .success(let response):
                    do {
                        let httpResponse = try JSONDecoder().decode(HTTPResponse<Ticker>.self, from: response.data)
                        observer.onNext(httpResponse.data)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
