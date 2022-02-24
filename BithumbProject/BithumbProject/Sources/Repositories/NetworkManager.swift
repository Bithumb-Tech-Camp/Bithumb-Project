//
//  NetworkManager.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/24.
//

import Foundation
import Moya
import RxSwift

class NetworkManager {
    private let provider = MoyaProvider<BithumbHTTPService>()
    
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
