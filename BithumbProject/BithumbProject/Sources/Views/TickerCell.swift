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
    }
    
    private let barView = UIView().then {
        $0.backgroundColor = .systemRed
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureUI()
        self.makeConstraints()
    }
    
    private func makeConstraints() {
        
        let tickerBarStackView = UIStackView(
            arrangedSubviews: [
                self.tickerLabel,
                self.barView
            ]).then {
                $0.axis = .vertical
                $0.spacing = 5
                $0.alignment = .leading
                $0.distribution = .fill
            }
        
//        self.barView.snp.makeConstraints { make in
//            make.width.equalTo(self.contentView.snp.width).multipliedBy(0.7)
//            make.height.equalTo(2)
//        }
        
        self.contentView.addSubview(tickerBarStackView)
        tickerBarStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.contentView.backgroundColor = .white
    }
}
