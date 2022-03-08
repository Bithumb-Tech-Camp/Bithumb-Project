//
//  CoinListType.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/04.
//

import Foundation

enum CoinListType: String, CaseIterable {
    case KRW = "원화"
    case popularity = "인기"
    case favorite = "관심"
    
    // 필요한 쿼리를 만들자.
    var query: String {
        switch self {
        case .KRW:
            return "All"
        case .favorite:
            return "All"
        case .popularity:
            return "My"
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

extension CoinListType: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.KRW, .KRW),
            (.popularity, .popularity),
            (.favorite, .favorite):
            return true
        default:
            return false
        }
    }
}

