//
//  TransactionCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/05.
//

import UIKit

import Then
import SnapKit
import SpreadsheetView

final class TransactionCell: Cell {
    
    private let transactionLabel = UILabel().then {
        $0.text = "49,230,124"
        $0.textColor = .black
        $0.textAlignment = .right
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.minimumScaleFactor = 0.5
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeConstraints()
    }
    
    private func makeConstraints() {
      
        self.contentView.addSubview(self.transactionLabel)
        self.transactionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

extension TransactionCell {
    func rendering(_ coin: Coin) {
        self.transactionLabel.text = coin.transaction.transactionDecimal
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
