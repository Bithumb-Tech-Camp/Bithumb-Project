//
//  PeriodTableViewCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/03.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

class PeriodTableViewCell: UITableViewCell {
    static let identifier = "PeriodTableViewCell"
    
    private let periodLabel = UILabel().then {
        $0.text = "어제대비"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .light)
        $0.textColor = .black
    }
    
    let checkImage = UIImageView().then {
        $0.image = nil
        $0.tintColor = .systemRed
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.makeConstrains()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.makeConstrains()
    }
    
    private func makeConstrains() {
        self.contentView.addSubview(self.periodLabel)
        self.contentView.addSubview(self.checkImage)
        
        self.periodLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
        }
        
        self.checkImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(30)
        }
    }
}

extension PeriodTableViewCell {
    func rendering(_ changeRatePeriod: ChangeRatePeriod) {
        self.periodLabel.text = changeRatePeriod.rawValue
    }
}
