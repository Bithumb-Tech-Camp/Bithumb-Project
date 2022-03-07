//
//  UIView+Extension.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/05.
//

import UIKit

extension CALayer {
    func addBorder(_ arrEdge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arrEdge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect(x: 0, y: 0, width: frame.width, height: width)
            case UIRectEdge.bottom:
                border.frame = CGRect(x: 0, y: frame.height - width, width: frame.width, height: width)
            case UIRectEdge.left:
                border.frame = CGRect(x: 0, y: 0, width: width, height: frame.height)
            case UIRectEdge.right:
                border.frame = CGRect(x: frame.width - width, y: 0, width: width, height: frame.height)
            default:
                break
            }
            border.backgroundColor = color.cgColor
            self.addSublayer(border)
        }
    }
}
