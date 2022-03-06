//
//  Color+Extension.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/03/07.
//

import Foundation
import UIKit

extension UIColor {
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    }
}
