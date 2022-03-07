//
//  StarCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/05.
//

import UIKit

import Then
import SnapKit
import SpreadsheetView

final class StarCell: Cell {
    
    let starButton = StarButton().then {
        $0.setState(false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureUI()
        self.makeConstraints()
    }
    
    private func makeConstraints() {
      
        self.contentView.addSubview(self.starButton)
        self.starButton.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.contentView.backgroundColor = .white
    }
}
