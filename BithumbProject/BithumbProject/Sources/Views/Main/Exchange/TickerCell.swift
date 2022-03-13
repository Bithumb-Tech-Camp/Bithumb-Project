//
//  TickerCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/05.
//

import UIKit

import Then
import SnapKit
import SpreadsheetView

final class TickerCell: Cell {
    
    private let tickerLabel = UILabel().then {
        $0.text = "49,230,124"
        $0.textAlignment = .right
        $0.textColor = .label
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.minimumScaleFactor = 0.5
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeConstraints()
    }
    
    private func makeConstraints() {
      
        self.contentView.addSubview(self.tickerLabel)
        self.tickerLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

extension TickerCell {
    func rendering(_ coin: Coin) {
        self.tickerLabel.text = coin.ticker.tickerDecimal
        let basicColor: UIColor = coin.changeRate.rate > 0 ? .systemRed : .systemBlue
        self.tickerLabel.textColor = basicColor
        
        if let isHigher = coin.isHigher {
            
            let changeBackColor: UIColor = isHigher ? .systemRed : .systemBlue
            self.tickerLabel.textColor = changeBackColor
            coin.wasHigher = isHigher
            
            UIView.animate(withDuration: 0.25) {
                self.contentView.backgroundColor = changeBackColor.withAlphaComponent(0.1)
            } completion: { _ in
                self.contentView.backgroundColor = .systemBackground
            }
        } else if let wasHigher = coin.wasHigher {
            let textColor: UIColor = wasHigher ? .systemRed : .systemBlue
            self.tickerLabel.textColor = textColor
            coin.wasHigher = wasHigher
            self.contentView.backgroundColor = .systemBackground
        } else {
            self.contentView.backgroundColor = .systemBackground
        }
    }
}
