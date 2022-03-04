//
//  ButtonBarCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/04.
//

import UIKit

import SnapKit
import Then

final class ButtonBarCell: UICollectionViewCell {
    static let idetifier = "ButtonBarCell"

    let contentLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = Font.defaultTextColor
        $0.font = Font.defaultFont
    }
    
    override var isSelected: Bool {
        didSet {
            self.updateUI(self.isSelected)
        }
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
        self.contentView.addSubview(self.contentLabel)
        self.contentLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.contentView.backgroundColor = .white
    }
    
    private func updateUI(_ isSelected: Bool) {
        let font = isSelected ? Font.selectedFont: Font.defaultFont
        let color = isSelected ? Font.selectedTextColor : Font.defaultTextColor
        self.contentLabel.font = font
        self.contentLabel.textColor = color
    }
}

extension ButtonBarCell {
    enum Font {
        fileprivate static let defaultFont: UIFont = .systemFont(ofSize: 17, weight: .semibold)
        fileprivate static let defaultTextColor: UIColor = .systemGray
        fileprivate static let selectedFont: UIFont = .systemFont(ofSize: 17, weight: .semibold)
        fileprivate static let selectedTextColor: UIColor = .black
    }
}
