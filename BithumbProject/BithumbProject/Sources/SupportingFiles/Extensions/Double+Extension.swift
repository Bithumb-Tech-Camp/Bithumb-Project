//
//  Int+Extension.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/02.
//

import Foundation

extension Double {
    var decimal: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 8
        return numberFormatter.string(for: self)
    }
}
