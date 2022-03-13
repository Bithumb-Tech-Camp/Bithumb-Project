//
//  SignUpTextField.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/13.
//

import UIKit

final class SignUpTextField: UITextField {
    
    // MARK: - Public Properties
    public var leftPadding: CGFloat = 10
    
    public var rightPadding: CGFloat = 10
    
    public var lineColor: UIColor = .systemGray4 {
        didSet {
            self.layer.borderColor = self.lineColor.cgColor
        }
    }
    
    // MARK: - override

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: self.leftPadding, bottom: 0, right: self.rightPadding))
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: self.leftPadding, bottom: 0, right: self.rightPadding))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: self.leftPadding, bottom: 0, right: self.rightPadding))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
    }
    
    private func configureUI() {
        self.borderStyle = .none
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    func updateUI(_ isValid: Bool) {
        if isValid {
            UIView.animate(withDuration: 0.2) {
                self.lineColor = .black
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.lineColor = .red
            }
        }
    }
    
}
