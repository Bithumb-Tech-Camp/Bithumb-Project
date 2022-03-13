//
//  TransactionSingleCell.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/03/09.
//

import Foundation
import SpreadsheetView
import Then
import SnapKit

class TransactionSingleCell: Cell {
    
    let label = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
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
            $0.left.equalTo(contentView).offset(10)
            $0.right.equalTo(contentView).offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
