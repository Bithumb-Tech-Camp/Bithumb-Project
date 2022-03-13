//
//  UpDown.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/12.
//

import UIKit

enum UpDown {
    case up
    case down
    
    var color: UIColor {
        self == .up ? .systemRed : .systemBlue
    }
}
