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
import RxCocoa
import RxSwift

protocol CellAction {
    func starButtonDidTap(_ coin: Coin)
}

final class StarCell: Cell {
    
    let starButton = StarButton().then {
        $0.setState(false)
    }
    
    var coin: Coin?
    
    var disposeBag = DisposeBag()

    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeConstraints()
        self.bind()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    private func makeConstraints() {
        self.contentView.addSubview(self.starButton)
        self.starButton.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
    }
    
    private func bind() {
        self.starButton.rx.tap
            .bind(onNext: { [weak self] _ in
                if let coin = self?.coin,
                   let value = self?.starButton.isActivated {
                    coin.star(value)
                }
            })
            .disposed(by: self.disposeBag)
    }
}

extension StarCell {
    func rendering(_ coin: Coin) {
        let coinName = "\(coin.acronyms)_\(coin.currency.rawValue)"
        let stars = CommonUserDefault<String>.fetch(.star(coinName))
        self.starButton.setState(stars.contains(where: { $0 == coinName }))
        
        if let isHigher = coin.isHigher {
            let changeBackColor: UIColor = isHigher ? .systemRed : .systemBlue
            UIView.animate(withDuration: 0.25) {
                self.contentView.backgroundColor = changeBackColor.withAlphaComponent(0.1)
            } completion: { _ in
                self.contentView.backgroundColor = .systemBackground
            }
        } else {
            self.contentView.backgroundColor = .systemBackground
        }
    }
}
