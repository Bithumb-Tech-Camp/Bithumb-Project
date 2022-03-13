//
//  CoinListType.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/04.
//

import Foundation

enum CoinListType: String, CaseIterable, Hashable {
    case KRW = "원화"
    case popularity = "인기"
    case favorite = "관심"
    
    var param: String {
        switch self {
        case .KRW:
            return "All"
        case .popularity:
            return "All"
        case .favorite:
            return "BTC_KRW" // UserDefault로 변경
        }
    }
    
    var row: Int {
        switch self {
        case .KRW:
            return 0
        case .popularity:
            return 1
        case .favorite:
            return 2
        }
    }
}
