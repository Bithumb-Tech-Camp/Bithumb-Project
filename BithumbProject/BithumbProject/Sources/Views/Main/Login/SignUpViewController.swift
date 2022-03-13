//
//  SignUpViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/13.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift

final class SignUpViewController: UIViewController {
    
    private let usernameLabel = UILabel().then {
        $0.text = "사용자 정보 등록"
        $0.textColor = .label
        $0.textAlignment = .left
    }
    
    private let userNameTextField = SignUpTextField().then {
        $0.placeholder = "이름을 적어 주세요"
        $0.leftPadding = 10
        $0.borderStyle = .none
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray6.cgColor
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let userAssetsTextField = SignUpTextField().then {
        $0.placeholder = "보유자산을 입력해 주세요"
        $0.leftPadding = 10
        $0.borderStyle = .none
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray6.cgColor
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let completionButton = UIButton().then {
        $0.setTitle("입력 완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemRed.withAlphaComponent(0.7)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeConstraints()
        self.configureUI()
        self.bind()
    }
    
    private func bind() {
        
        let userInfo = Observable.combineLatest(
            self.userNameTextField.rx.text.orEmpty,
            self.userAssetsTextField.rx.text.orEmpty) { name, assets in
                return User(name: name, assets: Double(assets) ?? 0.0)
            }

        self.completionButton.rx.tap
            .withLatestFrom(userInfo)
            .bind { [weak self] userInfo in
                guard let self = self else {
                    return
                }
                self.userAutoLogin(userInfo)
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: self.disposeBag)
    }
    
    func userAutoLogin(_ user: User) {
        CommonUserDefault<String>.initialSetting([
            .holdings: "\(user.assets)",
            .username: user.name,
            .changeRatePeriod: "24H"
        ])
        UserDefaults.standard.set(true, forKey: CommonUserDefault<String>.DataKey.initialLaunchKey.forKey)
    }
    
    private func makeConstraints() {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.usernameLabel,
                self.userNameTextField,
                self.userAssetsTextField,
                self.completionButton
            ]).then {
                $0.axis = .vertical
                $0.spacing = 10
                $0.alignment = .fill
                $0.distribution = .fillEqually
            }
        
        self.userNameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.view.backgroundColor = .systemBackground
    }
    
}
