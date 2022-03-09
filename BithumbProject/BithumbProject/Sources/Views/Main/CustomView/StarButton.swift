//
//  StarButton.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/05.
//

import UIKit
import Then

final class StarButton: UIButton {
    
    public var isActivated: Bool = false
    
    private let activeButtonImage = UIImage(
        systemName: "star.fill",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 15))
    
    private let inActiveButtonImage = UIImage(
        systemName: "star.fill",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 15))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    public func setState(_ newValue: Bool) {
        self.isActivated = newValue
        self.tintColor = self.isActivated ? .systemYellow : .systemGray5
        self.setImage(self.isActivated ? activeButtonImage : inActiveButtonImage, for: .normal)
    }
    
    @objc func buttonTapped() {
        self.isActivated.toggle()
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            guard let self = self else { return }
            self.tintColor = self.isActivated ? .systemYellow : .systemGray5
            let image = self.isActivated ? self.activeButtonImage : self.inActiveButtonImage
            self.transform = self.transform.scaledBy(x: 0.85, y: 0.85)
            self.setImage(image, for: .normal)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}
