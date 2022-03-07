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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .white
        self.label.text = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        contentView.addSubview(label)
        label.snp.makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.leading.equalTo(contentView).offset(5)
            $0.trailing.equalTo(contentView).offset(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
