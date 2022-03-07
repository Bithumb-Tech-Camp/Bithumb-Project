//
//  ChangeRateCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/05.
//

import UIKit

import Then
import SnapKit
import SpreadsheetView

final class ChangeRateCell: Cell {
    
    private let changeRateLabel = UILabel().then {
        $0.text = "-4.05%"
        $0.textColor = .systemBlue
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.minimumScaleFactor = 0.5
    }
    
    private let changeAmountLabel = UILabel().then {
        $0.text = "-1,356,124"
        $0.textColor = .systemBlue
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.minimumScaleFactor = 0.5
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
                self.changeRateLabel,
                self.changeAmountLabel
            ]).then {
                $0.axis = .vertical
                $0.spacing = 1
                $0.alignment = .trailing
                $0.distribution = .fill
            }
        
        self.contentView.addSubview(nameSymbolStackView)
        nameSymbolStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.contentView.backgroundColor = .white
    }
}
