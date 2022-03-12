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
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    private let withdrawalLabel = UILabel().then {
        $0.text = "출금 가능 여부"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    private let depositLabel = UILabel().then {
        $0.text = "예금 가능 여부"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeConstraints()
    }
    
    private func makeConstraints() {
        
    }

}

extension HoldingsTableViewCell {
    func rendering(holdings: Holdings) {
        self.coinNameLabel.text = holdings.coinName
        self.depositLabel.text = holdings.deposit
        self.withdrawalLabel.text = holdings.withdrawal
    }
}
