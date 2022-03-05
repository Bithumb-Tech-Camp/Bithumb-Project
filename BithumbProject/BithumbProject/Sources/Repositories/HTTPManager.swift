//
//  HTTPManager.swift
//  BithumbProject
//
// Created by 박형석 on 2022/02/24.
// Updated by Davy on 2022/02/27.

import Foundation

import Moya
import RxSwift

final class HTTPManager {
    private let provider: MoyaProvider<HTTPService>
    
    init(provider: MoyaProvider<HTTPService>) {
        self.provider = provider
    }
    
    func request<T: Codable>(httpServiceType: HTTPService, model: T.Type) -> Observable<T> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            self.provider.request(httpServiceType) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodeResponse = try JSONDecoder().decode(HTTPResponse<T>.self, from: response.data)
                        guard let data = decodeResponse.data else { return }
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
}
