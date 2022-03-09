//
//  StarCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/05.
//

import UIKit

import Then
import SnapKit
import SpreadsheetView

final class StarCell: Cell {
    
    let starButton = StarButton().then {
        $0.setState(false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeConstraints()
    }
    
    private func makeConstraints() {
      
        self.contentView.addSubview(self.starButton)
        self.starButton.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
    }
}

extension StarCell {
    func rendering(_ coin: Coin) {
        if let isHigher = coin.isHigher {
            let changeBackColor: UIColor = isHigher ? .systemRed : .systemBlue
            UIView.animate(withDuration: 0.2) {
                self.contentView.backgroundColor = changeBackColor.withAlphaComponent(0.1)
            } completion: { _ in
                self.contentView.backgroundColor = .systemBackground
            }
        } else {
            self.contentView.backgroundColor = .systemBackground
        }
    }
}
