//
//  Holdings.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/12.
//

import Foundation

final class Holdings {
    var coinName: String
    var currentDeposite: Double
    let deposit: Bool
    let withdrawal: Bool
    
    init(
        coinName: String,
        currentDeposite: Double = 0.0,
        deposit: Bool,
        withdrawal: Bool
    ) {
        self.coinName = coinName
        self.currentDeposite = currentDeposite
        self.deposit = deposit
        self.withdrawal = withdrawal
    }
}
