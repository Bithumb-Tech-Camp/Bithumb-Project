//
//  BithumbHTTPService.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/24.
//

import Foundation

import Moya

enum BithumbHTTPService {
    case ticker(_ orderCurrency: String)
    case assetsStatus(_ orderCurrency: String)
    case candleStick(_ orderCurrency: String, _ chartIntervals: String)
}

extension BithumbHTTPService: TargetType {
    var baseURL: URL {
        return URL(string: Constant.URL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .ticker(let orderCurrency):
            return Constant.Path.tickerPath + "/\(orderCurrency)"
        case .assetsStatus(let orderCurrency):
            return Constant.Path.assetsStatusPath + "/\(orderCurrency)"
        case .candleStick(let orderCurrency, let chartIntervals):
            return Constant.Path.candleStickPath + "/\(orderCurrency)" + "/\(chartIntervals)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return [
            "ContentType": "application/json"
        ]
    }
}
