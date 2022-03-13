//
//  TransactionViewController.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/03/06.
//

import UIKit
import RxSwift
import SpreadsheetView
import XLPagerTabStrip
import RxViewController

final class TransactionViewController: UIViewController, ViewModelBindable {
    
    let spreadSheetView = SpreadsheetView().then {
        $0.register(TransactionSingleCell.self, forCellWithReuseIdentifier: String(describing: TransactionSingleCell.self))
        $0.bounces = false
        $0.showsHorizontalScrollIndicator = false
        $0.intercellSpacing = CGSize(width: 0, height: 0)
        $0.gridStyle = .solid(width: 1, color: .systemGray5)
    }
    
    var transactionList: [TransactionHistory] = []
    var disposeBag: DisposeBag = DisposeBag()
    var viewModel: TransactionViewModel
    
    init(viewModel: TransactionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    private func configureUI() {
        self.spreadSheetView.dataSource = self
        
        view.addSubview(self.spreadSheetView)
        spreadSheetView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func bind() {
        self.viewModel.output.transactionData
            .map { [TransactionHistory(transactionDate: "시간", unitsTraded: "체결량", price: "가격")] + $0 }
            .subscribe(onNext: { [weak self] transactionList in
                self?.transactionList = transactionList
                self?.spreadSheetView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension TransactionViewController: SpreadsheetViewDataSource {
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 {
            return 100
        } else {
            return (Screen.width - 100) / 2
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow column: Int) -> CGFloat {
        return 30
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 3
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return self.transactionList.count
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TransactionSingleCell.self), for: indexPath) as? TransactionSingleCell
        
        if self.transactionList.count > 20 {
            let transaction = self.transactionList[indexPath.row]
            
            if indexPath.column == 0 {
                cell?.label.text = transaction.formattedDate ?? "시간"
            } else if indexPath.column == 1 {
                cell?.label.text = transaction.formattedPrice ?? "가격(\(self.viewModel.coin.currency))"
            } else if indexPath.column == 2 {
                cell?.label.text = transaction.formattedUnitsTraded ?? "체결량(\(self.viewModel.coin.acronyms))"
            }
            
            if indexPath.row == 0 || indexPath.column == 0 {
                cell?.label.textColor = .black
                cell?.label.textAlignment = .center
            } else {
                cell?.label.textColor = transaction.formattedUpdown.color
                cell?.label.textAlignment = .right
            }
            
            if indexPath.row == 0 {
                cell?.borders.top = .solid(width: 1, color: .darkGray)
                cell?.borders.bottom = .solid(width: 1, color: .darkGray)
            }
            
        }
        return cell
    }
}

extension TransactionViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: "시세")
    }
}
