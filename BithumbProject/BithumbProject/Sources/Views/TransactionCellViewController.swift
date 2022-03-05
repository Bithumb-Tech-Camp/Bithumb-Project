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

class TransactionCellViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel = TransactionCellViewModel()
    
    let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.separatorInset = .zero
        $0.register(TransactionSmallCell.self, forCellReuseIdentifier: String(describing: TransactionSmallCell.self))
        $0.rowHeight = 20
        $0.backgroundColor = .white
        $0.isScrollEnabled = false
        $0.allowsSelection = false
    }
 
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        bindViewModel()
    }
    
    func setup(to target: UIViewController) {
        target.addChild(self)
        self.didMove(toParent: target)
    }
    
    func attach(to view: UIView) {
        self.view.backgroundColor = .green
        
        view.addSubview(self.view)
        self.view.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.view)
            $0.leading.equalTo(self.view)
            $0.trailing.equalTo(self.view)
            $0.bottom.equalTo(self.view)
        }
    }
    
    private func bindViewModel() {
        viewModel.output.transactionData
            .map { $0.sorted { $0.transactionDate ?? "" > $1.transactionDate ?? "" }}
            .map { [TransactionHistory(unitsTraded: "체결량", price: "체결가")] + $0[0..<20] }
            .bind(to: self.tableView.rx.items(cellIdentifier: String(describing: TransactionSmallCell.self), cellType: TransactionSmallCell.self)) { (row, dataSource, cell) in
                cell.contractPriceLabel.text = dataSource.price
                cell.contractQuantityLabel.text = dataSource.unitsTraded
                if row != 0 {
                    cell.contractPriceLabel.textColor = dataSource.updown == "dn" ? .blue : .red
                    cell.contractQuantityLabel.textColor = dataSource.updown == "dn" ? .blue : .red
                }
            }
            .disposed(by: disposeBag)
    }
}
