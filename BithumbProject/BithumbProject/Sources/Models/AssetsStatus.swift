//
//  AssetsStatus.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/23.
//

import Foundation

struct AssetsStatus: Codable {
    var depositStatus: Int?
    var withdrawalStatus: Int?
    
    enum CodingKeys: String, CodingKey {
        case depositStatus = "deposit_status"
        case withdrawalStatus = "withdrawal_status"
    }
}

extension AssetsStatus {
    func toDomain() -> Holdings {
        let deposit: Bool = self.depositStatus == 1 ? true : false
        let withdrawal: Bool = self.withdrawalStatus == 1 ? true : false
        return Holdings(coinName: "비트코인", deposit: deposit, withdrawal: withdrawal)
    }
}
