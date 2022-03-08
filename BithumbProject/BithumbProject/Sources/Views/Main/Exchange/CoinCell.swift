//
//  CoinCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/04.
//

import UIKit

import Then
import SnapKit
import SpreadsheetView

final class CoinCell: Cell {
    
    private let nameLabel = UILabel().then {
        $0.text = "비트코인"
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    private let symbolLabel = UILabel().then {
        $0.text = "BTC/KRW"
        $0.textColor = .systemGray
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
        self.makeConstraints()
    }
    
    private func makeConstraints() {
        let nameSymbolStackView = UIStackView(
            arrangedSubviews: [
                self.nameLabel,
                self.symbolLabel
            ]).then {
                $0.axis = .vertical
                $0.spacing = 1
                $0.alignment = .leading
                $0.distribution = .fill
            }
        
        self.contentView.addSubview(nameSymbolStackView)
        nameSymbolStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.contentView.backgroundColor = .white
    }
}

extension CoinCell {
    func rendering(_ coin: Coin) {
        self.nameLabel.text = coin.krName
        self.symbolLabel.text = coin.symbol
    }
}
