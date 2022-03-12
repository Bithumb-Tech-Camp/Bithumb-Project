//
//  HoldingsHeaderView.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/12.
//

import UIKit

final class HoldingsHeaderView: UIView {
    
    private let usernameLabel = UILabel().then {
        $0.text = CommonUserDefault<String>.fetch(.username).first
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
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
        self.addSubview(self.usernameLabel)
        self.usernameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        let stackView = UIStackView(
            arrangedSubviews: [
                self.titleLabel,
                self.holdingsLabel
            ]).then {
                $0.axis = .vertical
                $0.spacing = 10
                $0.alignment = .trailing
                $0.distribution = .fillEqually
            }
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
        }
    }
    
    private func configureUI() {
        self.backgroundColor = .systemGray6
    }

}
