//
//  NetworkManager.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/24.
//

import Foundation
import Moya
import RxSwift

class HTTPManager {
    private let provider = MoyaProvider<BithumbHTTPService>()
    
    // TODO: - 코인 리스트 내역
    func requestCoinList() -> Observable<[Coin]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            self.provider.request(.assetsStatus()) { result in
                switch result {
                case .success(let response):
                    guard let response = try? JSONDecoder().decode(HTTPResponse<[String:AssetsStatus]>.self, from: response.data),
                          let data = response.data else {
                        return
                    }
                    let coinList = data.keys.map { Coin(name: $0) }
                    observer.onNext(coinList)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    // TODO: - 현재가
//    func
    
    // TODO: - 입출금 현황
    
    func request(with query: String) -> Observable<[String]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            self.provider.request(.assetsStatus(query)) { result in
                switch result {
                case .success(let reponse):
                    observer.onNext([])
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
}
