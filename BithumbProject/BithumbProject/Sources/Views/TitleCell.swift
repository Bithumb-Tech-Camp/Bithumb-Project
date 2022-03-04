//
//  TitleCell.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/04.
//

import UIKit

import Then
import SnapKit

final class TitleCell: UITableViewCell {
    static let identifier = "TitleCell"
    
    let sortingButton = UIButton().then {
        $0.setTitle("가산", for: .normal)
    }
    
    private let sortingImage = UIImageView().then {
        $0.image = UIImage(systemName: "eject.fill", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 10))
        $0.tintColor = .gray
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureUI()
        self.makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
        self.makeConstraints()
    }
    
    private func makeConstraints() {
        
        let sortingStackView = UIStackView(
            arrangedSubviews: [
                self.sortingButton,
                self.sortingImage
            ]).then {
                $0.distribution = .fill
                $0.alignment = .center
                $0.axis = .horizontal
                $0.spacing  = 0
            }
        
        self.contentView.addSubview(sortingStackView)
        sortingStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.contentView.backgroundColor = .white
    }
}
