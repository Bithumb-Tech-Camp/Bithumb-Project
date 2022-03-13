//
//  HoldingsViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/09.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift

final class HoldingsViewController: UIViewController, ViewModelBindable {
      
    var viewModel: HoldingsViewModel
    var disposeBag: DisposeBag = DisposeBag()
    
    private let alarmBarButton = UIBarButtonItem().then {
        $0.image = UIImage(systemName: "bell")
        $0.tintColor = .black
    }
    
    private let holdingsTableView = UITableView(frame: .zero, style: .grouped).then {
        $0.register(HoldingsTableViewCell.self,
                    forCellReuseIdentifier: String(describing: HoldingsTableViewCell.self))
    }
    
    private let holdingsHeaderView = HoldingsHeaderView()
    
    init(viewModel: HoldingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
        self.configureNavigationBarUI()
        self.makeConstraints()
    }
    
    func bind() {
        
        self.rx.viewWillAppear
            .bind { _ in
                let user = User(
                    name: CommonUserDefault<String>.fetch(.username).first ?? "",
                    assets: Double(CommonUserDefault<String>.fetch(.holdings).first ?? "") ?? 0.0)
                self.viewModel.output.userInfo.accept(user)
            }
            .disposed(by: self.disposeBag)
        
        self.alarmBarButton.rx.tap
            .bind { _ in
                self.alertMessage(message: "알림이 설정되었습니다")
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.holdings
            .bind(to: holdingsTableView.rx.items(cellIdentifier: String(describing: HoldingsTableViewCell.self), cellType: HoldingsTableViewCell.self)) { _, item, cell in
                cell.selectionStyle = .none
                cell.rendering(holdings: item)
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.userInfo
            .bind(onNext: { [weak self] user in
                guard let self = self,
                let user = user else { return }
                self.holdingsHeaderView.rendering(user)
            })
            .disposed(by: self.disposeBag)
        
        self.holdingsTableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
    }
    
    private func makeConstraints() {
        self.view.addSubview(self.holdingsTableView)
        self.holdingsTableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
        }
    }
    
    private func configureNavigationBarUI() {
        self.navigationItem.title = "입출금"
        self.navigationItem.rightBarButtonItem = self.alarmBarButton
    }
    
}

extension HoldingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.holdingsHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
