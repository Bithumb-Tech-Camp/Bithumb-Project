//
//  OrderBookCell.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/26.
//

import Foundation
import SpreadsheetView
import Then
import SnapKit

class OrderBookPriceCell: Cell {
    
    let priceLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textAlignment = .right
    }
    
    let percentLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 10, weight: .light)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .white
        self.priceLabel.text = ""
        self.percentLabel.text = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        
        let stackView = UIStackView(
            arrangedSubviews: [
                self.priceLabel,
                self.percentLabel
            ])
            .then {
                $0.axis = .horizontal
                $0.alignment = .center
                $0.distribution = .fill
                $0.spacing = 5
            }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.leading.equalTo(contentView).offset(10)
            $0.trailing.equalTo(contentView).offset(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
