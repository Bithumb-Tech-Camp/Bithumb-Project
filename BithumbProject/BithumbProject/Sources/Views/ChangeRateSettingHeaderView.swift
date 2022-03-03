//
//  ChangeRateSettingHeaderView.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/03.
//

import UIKit

import SnapKit
import Then

final class ChangeRateSettingHeaderView: UIView {
    
    private let titleLabel = UILabel().then {
        $0.text = "변동률 기간 설정"
        $0.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = """
        APP 내 데이터 기준 기간이 모두 동일하게 변경됩니다.
        거래금액은 최근 24시간 기준으로 표기됩니다.
        """
        $0.font = UIFont.systemFont(ofSize: 15, weight: .light)
        $0.textColor = .systemGray
        $0.numberOfLines = 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeConstrains()
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.makeConstrains()
        self.configureUI()
    }
    
    private func makeConstrains() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.descriptionLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(30)
        }
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.bottom.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.backgroundColor = .systemBackground
    }
}
