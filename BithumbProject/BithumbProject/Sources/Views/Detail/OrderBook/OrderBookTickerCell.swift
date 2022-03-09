//
//  OrderBookTickerCell.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/03/02.
//

import Foundation
import SpreadsheetView
import Then
import SnapKit
import UIKit

class OrderBookTickerCell: Cell {
    
    let lowPriceLabel = LeftTitleLabel().then {
        $0.title = "저가(1H)"
        $0.content("", color: .blue)
    }
    
    let highPriceLabel = LeftTitleLabel().then {
        $0.title = "고가(1H)"
        $0.content("", color: .red)
    }
    
    let openPriceLabel = LeftTitleLabel().then {
        $0.title = "시가(1H)"
    }
    
    let prevClosePriceLabel = LeftTitleLabel().then {
        $0.title = "전일종가"
    }
    
    let separateView = UIView().then {
        $0.backgroundColor = .lightGray
    }
    
    let accTradeValueLabel = LeftTitleLabel().then {
        $0.title = "거래금"
    }
    
    let unitsTradedLabel = LeftTitleLabel().then {
        $0.title = "거래량"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.separateView.snp.makeConstraints {
            $0.height.equalTo(0.5)
        }
        
        let contentStackView = UIStackView(
            arrangedSubviews: [
                self.unitsTradedLabel,
                self.accTradeValueLabel,
                self.separateView,
                self.prevClosePriceLabel,
                self.openPriceLabel,
                self.highPriceLabel,
                self.lowPriceLabel
            ])
            .then {
                $0.axis = .vertical
                $0.alignment = .fill
                $0.distribution = .fill
                $0.spacing = 5
            }
        
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.leading.equalTo(self.contentView).offset(5)
            $0.trailing.equalTo(self.contentView).offset(-5)
            $0.bottom.equalTo(self.contentView).offset(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class LeftTitleLabel: UIView {
    public var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    public var content: String? {
        get { return contentLabel.text }
        set { contentLabel.text = newValue }
    }
    
    public func content(_ text: String, color: UIColor) {
        self.contentLabel.text = text
        self.contentLabel.textColor = color
        self.contentLabel.textAlignment = .right
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10, weight: .light)
        $0.textColor = .lightGray
        $0.textAlignment = .left
    }
    private let contentLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10, weight: .light)
        $0.textColor = .lightGray
        $0.numberOfLines = 0
        $0.textAlignment = .right
    }

    convenience init() {
        self.init(frame: .zero)
        
        let contentStackView = UIStackView(
            arrangedSubviews: [
                self.titleLabel,
                self.contentLabel
            ])
            .then {
                $0.axis = .horizontal
                $0.alignment = .top
                $0.distribution = .fill
                $0.spacing = 10
            }

        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(self)
            $0.leading.equalTo(self)
            $0.trailing.equalTo(self)
            $0.bottom.equalTo(self)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
