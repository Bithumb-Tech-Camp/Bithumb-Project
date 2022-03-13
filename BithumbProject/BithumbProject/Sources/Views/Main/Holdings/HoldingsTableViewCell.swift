//
//  HoldingsTableViewCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/12.
//

import UIKit

import SnapKit
import Then

class HoldingsTableViewCell: UITableViewCell {
    
    private let coinNameLabel = UILabel().then {
        $0.text = "원화"
        $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }
    
    private let holdingsRateLabel = UILabel().then {
        $0.text = "0.00%"
        $0.font = UIFont.systemFont(ofSize: 15, weight: .light)
        $0.textColor = .systemGray
    }
    
    private let withdrawalLabel = UILabel().then {
        $0.text = "출금 가능 여부"
        $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }
    
    private let depositLabel = UILabel().then {
        $0.text = "예금 가능 여부"
        $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeConstraints()
    }
    
    private func makeConstraints() {
        
        let holdingsStackView = UIStackView(
            arrangedSubviews: [
                self.coinNameLabel,
                self.holdingsRateLabel
            ]).then {
                $0.axis = .vertical
                $0.spacing = 10
                $0.alignment = .leading
                $0.distribution = .fillEqually
            }
        
        self.contentView.addSubview(holdingsStackView)
        holdingsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(15)
        }
        
        let statusStackView = UIStackView(
            arrangedSubviews: [
                self.depositLabel,
                self.withdrawalLabel
            ]).then {
                $0.axis = .vertical
                $0.spacing = 10
                $0.alignment = .trailing
                $0.distribution = .fillEqually
            }
        
        self.contentView.addSubview(statusStackView)
        statusStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(15)
        }
    }

}

extension HoldingsTableViewCell {
    func rendering(holdings: Holdings) {
        let depositText: String = holdings.deposit ? "입금 가능" : "입금 불가능"
        let depositTextColor: UIColor = holdings.deposit ? .label : .systemGray
        
        let withdrawalText: String = holdings.withdrawal ? "출금 가능" : "출금 불가능"
        let withdrawalTextColor: UIColor = holdings.withdrawal ? .label : .systemGray
        
        self.coinNameLabel.text = "\(holdings.coinName)"
        
        let userAssets = Double(CommonUserDefault<String>.fetch(.holdings).first ?? "") ?? 0.0
        let holdingsRate = (holdings.currentDeposite / userAssets) * 100
        self.holdingsRateLabel.text = "\(holdingsRate) %"
        
        self.depositLabel.text = depositText
        self.depositLabel.textColor = depositTextColor
        self.withdrawalLabel.text = withdrawalText
        self.withdrawalLabel.textColor = withdrawalTextColor
    }
}
