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
    
    private let buttonImage: (CGFloat) -> UIImage? = { pointSize in
        UIImage(
            systemName: "star.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize)
        )
    }
    
    init(isActivated: Bool = false, pointSize: CGFloat = 15) {
        super.init(frame: .zero)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.setImage(buttonImage(pointSize), for: .normal)
        self.setState(isActivated)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    public func setState(_ newValue: Bool) {
        self.isActivated = newValue
        self.tintColor = self.isActivated ? .systemYellow : .systemGray5
    }
    
    @objc func buttonTapped() {
        self.isActivated.toggle()
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            guard let self = self else { return }
            self.transform = self.transform.scaledBy(x: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}
