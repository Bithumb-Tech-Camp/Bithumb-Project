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

class OrderBookCell: Cell {
    
    let label = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        contentView.addSubview(label)
        label.snp.makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.right.equalTo(contentView).inset(5)
            $0.left.equalTo(contentView).inset(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
