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
        $0.textColor = .systemBlue
        $0.textAlignment = .right
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.minimumScaleFactor = 0.5
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureUI()
        self.makeConstraints()
    }
    
    private func makeConstraints() {
      
        self.contentView.addSubview(self.tickerLabel)
        self.tickerLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.contentView.backgroundColor = .white
    }
}

extension TickerCell {
    func rendering(_ coin: Coin) {
        self.tickerLabel.text = coin.ticker.tickerDecimal
    }
}
