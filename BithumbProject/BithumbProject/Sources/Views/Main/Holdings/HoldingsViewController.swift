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
    }
    
    func bind() {
        
        self.alarmBarButton.rx.tap
            .bind { _ in
                
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.holdings
            .bind(to: holdingsTableView.rx.items(cellIdentifier: String(describing: HoldingsTableViewCell.self), cellType: HoldingsTableViewCell.self)) { row, item, cell in
                
            }
            .disposed(by: self.disposeBag)
        
        self.holdingsTableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
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
        return 100
    }
}
