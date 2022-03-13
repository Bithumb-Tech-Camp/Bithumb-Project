//
//  TransactionCellViewController.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/03/04.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources

final class TransactionCellViewController: UIViewController, ViewModelBindable {
    
    let volumePowerTitleLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 12, weight: .light)
        $0.textAlignment = .left
        $0.text = "체결강도"
    }
    
    let volumePowerLabel = UILabel().then {
        $0.textColor = .red
        $0.font = UIFont.systemFont(ofSize: 12, weight: .light)
        $0.textAlignment = .right
    }
    
    let volumeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 10
    }
    
    let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.separatorInset = .zero
        $0.register(TransactionSmallCell.self, forCellReuseIdentifier: String(describing: TransactionSmallCell.self))
        $0.rowHeight = 20
        $0.backgroundColor = .white
        $0.isScrollEnabled = false
        $0.allowsSelection = false
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    var viewModel: TransactionViewModel
    
    init(viewModel: TransactionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        bind()
    }
    
    func setup(to target: UIViewController) {
        target.addChild(self)
        self.didMove(toParent: target)
    }
    
    func attach(to view: UIView) {
        self.view.backgroundColor = .white
        
        view.addSubview(self.view)
        self.view.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
        
        [self.volumePowerTitleLabel, self.volumePowerLabel].forEach {
            self.volumeStackView.addArrangedSubview($0)
        }
        
        self.view.addSubview(self.volumeStackView)
        self.volumeStackView.snp.makeConstraints {
            $0.top.equalTo(self.view).offset(10)
            $0.leading.equalTo(self.view).offset(3)
            $0.trailing.equalTo(self.view).offset(-3)
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.volumeStackView.snp.bottom).offset(10)
            $0.leading.equalTo(self.view)
            $0.trailing.equalTo(self.view)
            $0.bottom.equalTo(self.view)
        }
    }
    
    func bind() {
        viewModel.output.transactionData
            .map { $0.prefix(26) }
            .bind(to: self.tableView.rx.items(cellIdentifier: String(describing: TransactionSmallCell.self), cellType: TransactionSmallCell.self)) { (_, dataSource, cell) in
                cell.contractPriceLabel.text = dataSource.formattedPrice ?? ""
                cell.contractQuantityLabel.text = dataSource.formattedUnitsTraded ?? ""
                cell.contractPriceLabel.textColor = dataSource.formattedUpdown.color
                cell.contractQuantityLabel.textColor = dataSource.formattedUpdown.color
            }
            .disposed(by: disposeBag)
        
        viewModel.output.volumePower
            .map { $0 + "%" }
            .bind(to: self.volumePowerLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
