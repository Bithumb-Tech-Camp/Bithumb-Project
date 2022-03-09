//
//  TitleCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/04.
//

import UIKit

import Then
import SnapKit
import SpreadsheetView

final class TitleCell: Cell {
    
    let sortTypeLabel = UILabel().then {
        $0.text = "현재가 \u{25B2}"
        $0.textColor = .systemGray
        $0.textAlignment = .left
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
        self.contentView.addSubview(self.sortTypeLabel)
        self.sortTypeLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.right.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }
    }
    
    private func configureUI() {
        self.contentView.backgroundColor = .white
    }
}
