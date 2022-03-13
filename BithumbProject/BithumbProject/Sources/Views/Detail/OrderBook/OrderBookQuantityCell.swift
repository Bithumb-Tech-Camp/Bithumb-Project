//
//  OrderBookQuantityCell.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/03/09.
//

import Foundation
import SpreadsheetView
import Then
import SnapKit

class OrderBookQuantityCell: Cell {
    
    let quantityLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 11, weight: .regular)
    }
    
    let quantityBar = UIView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .white
        self.quantityLabel.text = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        
        contentView.addSubview(quantityBar)
        quantityBar.snp.makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.height.equalTo(10)
        }
        
        contentView.addSubview(quantityLabel)
        quantityLabel.snp.makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.leading.equalTo(contentView).offset(5)
            $0.trailing.equalTo(contentView).offset(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
