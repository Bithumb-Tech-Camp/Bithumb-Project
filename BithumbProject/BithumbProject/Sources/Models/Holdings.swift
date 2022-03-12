//
//  Holdings.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/12.
//

import Foundation

final class Holdings {
    var coinName: String
    let deposit: Bool
    let withdrawal: Bool
    
    init(
        coinName: String,
        deposit: Bool,
        withdrawal: Bool
    ) {
        self.coinName = coinName
        self.deposit = deposit
        self.withdrawal = withdrawal
    }
}
