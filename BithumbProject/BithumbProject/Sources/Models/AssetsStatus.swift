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
