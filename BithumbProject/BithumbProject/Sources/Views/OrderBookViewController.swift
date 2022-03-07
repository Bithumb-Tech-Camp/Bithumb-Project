//
//  OrderBookViewController.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/26.
//

import Foundation
import UIKit
import RxSwift
import SpreadsheetView
import RxDataSources

class OrderBookViewController: UIViewController {
    var disposeBag = DisposeBag()
    let viewModel = OrderBookViewModel()
    let transactionCellViewController = TransactionCellViewController()
    
    let spreadSheetView = SpreadsheetView().then {
        $0.register(OrderBookCell.self, forCellWithReuseIdentifier: String(describing: OrderBookCell.self))
        $0.register(OrderBookTickerCell.self, forCellWithReuseIdentifier: String(describing: OrderBookTickerCell.self))
        $0.register(OrderBookTransactionCell.self, forCellWithReuseIdentifier: String(describing: OrderBookTransactionCell.self))
        $0.bounces = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    var bidList: [BidAsk] = []  // 매수
    var askList: [BidAsk] = []  // 매도
    var tickerData: RealtimeTicker = RealtimeTicker()
    var prevClosePrice: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        self.spreadSheetView.delegate = self
        self.spreadSheetView.dataSource = self
        
        view.addSubview(self.spreadSheetView)
        spreadSheetView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets.zero)
        }
        
        self.viewModel.output.bidList
            .subscribe(onNext: { bidList in
                self.bidList = bidList
                self.spreadSheetView.reloadData()
            })
            .disposed(by: disposeBag)

        self.viewModel.output.askList
            .subscribe(onNext: { askList in
                self.askList = askList
                self.spreadSheetView.reloadData()
            })
            .disposed(by: disposeBag)

        self.viewModel.output.tickerData
            .subscribe(onNext: { ticker in
                self.tickerData = ticker
                self.spreadSheetView.reloadData()
            })
            .disposed(by: disposeBag)
        
        self.viewModel.output.prevClosePrice
            .bind(to: self.rx.prevClosePrice)
            .disposed(by: disposeBag)
    }
}

extension OrderBookViewController: SpreadsheetViewDelegate {
    
}

extension OrderBookViewController: SpreadsheetViewDataSource {
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return Screen.width / 3
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 30
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        3
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        60
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        return [
            CellRange(from: (row: 0, column: 2), to: (row: 29, column: 2)),
            CellRange(from: (row: 30, column: 0), to: (row: 59, column: 0))
        ]
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.row == 0 && indexPath.column == 2 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookTickerCell.self), for: indexPath) as? OrderBookTickerCell
            cell?.lowPriceLabel.content = self.tickerData.lowPrice
            cell?.highPriceLabel.content = self.tickerData.highPrice
            cell?.openPriceLabel.content = self.tickerData.openPrice
            cell?.prevClosePriceLabel.content = self.tickerData.prevClosePrice
            cell?.accTradeValueLabel.content = self.tickerData.value
            cell?.unitsTradedLabel.content = self.tickerData.volume
            return cell
        } else if indexPath.row == 30 && indexPath.column == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookTransactionCell.self), for: indexPath)
            cell.layoutIfNeeded()
            if self.children.isEmpty {
                transactionCellViewController.setup(to: self)
            }
            transactionCellViewController.attach(to: cell.contentView)
            return cell
        } else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookCell.self), for: indexPath) as? OrderBookCell
            if !self.askList.isEmpty && !self.bidList.isEmpty {
                if indexPath.column ==  0 && indexPath.row < 30 {
                    cell?.label.text = self.askList[indexPath.row].quantity
                    cell?.label.textAlignment = .right
                    cell?.contentView.backgroundColor = Color.backgroundBlue
                    cell?.label.textColor = self.prevClosePrice <= self.askList[indexPath.row].price ?? "" ? .systemRed : .systemBlue
                }
                
                if indexPath.column ==  1 {
                    if indexPath.row < 30 {
                        cell?.label.text = self.askList[indexPath.row].price
                        cell?.label.textAlignment = .center
                        cell?.contentView.backgroundColor = Color.backgroundBlue
                        cell?.label.textColor = self.prevClosePrice <= self.askList[indexPath.row].price ?? "" ? .systemRed : .systemBlue
                        
                        if self.askList[indexPath.row].price ?? "" == self.tickerData.closePrice ?? "" {
                            cell?.borders.top = .solid(width: 1, color: .black)
                            cell?.borders.left = .solid(width: 1, color: .black)
                            cell?.borders.right = .solid(width: 1, color: .black)
                            cell?.borders.bottom = .solid(width: 1, color: .black)
                        }
                    } else {
                        cell?.label.text = self.bidList[indexPath.row-30].price
                        cell?.label.textAlignment = .center
                        cell?.contentView.backgroundColor = Color.backgroundRed
                        cell?.label.textColor = self.prevClosePrice <= self.bidList[indexPath.row - 30].price ?? "" ? .systemRed : .systemBlue
                        
                        if self.bidList[indexPath.row - 30].price ?? "" == self.tickerData.closePrice ?? "" {
                            cell?.borders.top = .solid(width: 1, color: .black)
                            cell?.borders.left = .solid(width: 1, color: .black)
                            cell?.borders.right = .solid(width: 1, color: .black)
                            cell?.borders.bottom = .solid(width: 1, color: .black)
                        }
                    }
                }
                
                if indexPath.column ==  2 && indexPath.row >= 30 {
                    cell?.label.text = self.bidList[indexPath.row-30].quantity
                    cell?.label.textAlignment = .left
                    cell?.contentView.backgroundColor = Color.backgroundRed
                    cell?.label.textColor = self.prevClosePrice <= self.bidList[indexPath.row - 30].price ?? "" ? .systemRed : .systemBlue
                }
            }
            return cell
        }
    }
}
