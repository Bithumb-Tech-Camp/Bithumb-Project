//
//  ChangeRate.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/05.
//

import UIKit

struct ChangeRate {
    let rate: Double
    let amount: Double
    
    var changeRateColor: UIColor {
        if self.rate <= 0 {
            return .systemBlue
        } else {
            return .systemRed
        }
    }
}
