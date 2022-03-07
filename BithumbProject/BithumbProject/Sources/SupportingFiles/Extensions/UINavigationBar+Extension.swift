//
//  UINavigationBar+Extension.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/05.
//

import UIKit

extension UINavigationBar {
    func transparentNavigationBar() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
    }
}
