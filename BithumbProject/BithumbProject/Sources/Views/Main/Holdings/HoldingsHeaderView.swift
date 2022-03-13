//
//  HoldingsHeaderView.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/12.
//

import UIKit

final class HoldingsHeaderView: UIView {
    
    private let usernameTitleLabel = UILabel().then {
        $0.text = "사용자"
        $0.font = UIFont.systemFont(ofSize: 15, weight: .light)
        $0.textColor = .systemGray
    }
    
    private let usernameLabel = UILabel().then {
        $0.text = CommonUserDefault<String>.fetch(.username).first
        $0.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        $0.textColor = .darkGray
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "보유자산"
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    private let holdingsLabel = UILabel().then {
        $0.text = "3,000원"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .medium)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeConstraints()
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.makeConstraints()
        self.configureUI()
    }
    
    private func makeConstraints() {
        
        let userStackView = UIStackView(
            arrangedSubviews: [
                self.usernameTitleLabel,
                self.usernameLabel
            ]).then {
                $0.axis = .vertical
                $0.spacing = 0
                $0.alignment = .leading
                $0.distribution = .fillEqually
            }
        
        self.addSubview(userStackView)
        userStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        let stackView = UIStackView(
            arrangedSubviews: [
                self.titleLabel,
                self.holdingsLabel
            ]).then {
                $0.axis = .vertical
                $0.spacing = 5
                $0.alignment = .trailing
                $0.distribution = .fillEqually
            }
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func configureUI() {
        self.backgroundColor = .systemGray6.withAlphaComponent(0.5)
    }

}

extension HoldingsHeaderView {
    func rendering(_ user: User) {
        self.usernameLabel.text = user.name
        self.holdingsLabel.text = user.assets.userAssetsDecimal
    }
}
