//
//  TransactionSmallCell.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/03/05.
//

import Foundation
import SpreadsheetView
import Then
import SnapKit

class TransactionSmallCell: UITableViewCell {
    static let identifier = "TransactionSmallCell"
    
    let contractPriceLabel = UILabel().then {
        $0.text = "체결가격"
        $0.font = UIFont.systemFont(ofSize: 10, weight: .light)
        $0.textColor = .black
        $0.textAlignment = .left
    }
    
    let contractQuantityLabel = UILabel().then {
        $0.text = "체결수량"
        $0.font = UIFont.systemFont(ofSize: 10, weight: .light)
        $0.textColor = .black
        $0.textAlignment = .right
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contractPriceLabel.textColor = .black
        self.contractQuantityLabel.textColor = .black
    }
    
    private func makeConstrains() {
        let contractStackView = UIStackView(
            arrangedSubviews: [
                self.contractPriceLabel,
                self.contractQuantityLabel
            ])
            .then {
                $0.axis = .horizontal
                $0.alignment = .leading
                $0.distribution = .fill
                $0.spacing = 10
            }
        
        self.contentView.addSubview(contractStackView)
        contractStackView.snp.makeConstraints {
            $0.leading.equalTo(self.contentView).offset(3)
            $0.centerY.equalTo(self.contentView)
            $0.trailing.equalTo(self.contentView).offset(-3)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.makeConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
