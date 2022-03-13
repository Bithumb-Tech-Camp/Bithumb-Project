//
//  HTTPService.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/24.
//

import Foundation

import Moya

typealias OrderCurrency = String

enum HTTPService {
    case ticker(_ orderCurrency: OrderCurrency)
    case assetsStatus(_ orderCurrency: OrderCurrency = "All")
    case candleStick(_ orderCurrency: OrderCurrency, _ chartIntervals: String)
    case orderBook(_ orderCurrency: OrderCurrency)
    case transactionHistory(_ orderCurrency: OrderCurrency)
}

extension HTTPService: TargetType {
    var baseURL: URL {
        return URL(string: Constant.URL.httpBaseURL)!
    }
    
    var path: String {
        switch self {
        case .ticker(let orderCurrency):
            return Constant.Path.tickerPath + "/\(orderCurrency)"
        case .assetsStatus(let orderCurrency):
            return Constant.Path.assetsStatusPath + "/\(orderCurrency)"
        case .candleStick(let orderCurrency, let chartIntervals):
            return Constant.Path.candleStickPath + "/\(orderCurrency)" + "/\(chartIntervals)"
        case .orderBook(let orderCurrency):
            return Constant.Path.orderBookPath + "/\(orderCurrency)"
        case .transactionHistory(let orderCurrency):
            return Constant.Path.transationHistoryPath + "/\(orderCurrency)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String: String]? {
        return [
            "ContentType": "application/json"
        ]
    }
}
