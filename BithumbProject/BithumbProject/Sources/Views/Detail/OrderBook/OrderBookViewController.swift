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
import XLPagerTabStrip

final class OrderBookViewController: UIViewController, ViewModelBindable {

    private let spreadSheetView = SpreadsheetView().then {
        $0.register(OrderBookPriceCell.self, forCellWithReuseIdentifier: String(describing: OrderBookPriceCell.self))
        $0.register(OrderBookTickerCell.self, forCellWithReuseIdentifier: String(describing: OrderBookTickerCell.self))
        $0.register(OrderBookTransactionCell.self, forCellWithReuseIdentifier: String(describing: OrderBookTransactionCell.self))
        $0.bounces = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    var bidList: [BidAsk] = []  // 매수
    var askList: [BidAsk] = []  // 매도
    var tickerData: Ticker = Ticker()
    var realTimeTickerData: RealtimeTicker = RealtimeTicker()
    var prevClosePrice: String = ""
    var closePrice: String = ""
    
    var disposeBag: DisposeBag = DisposeBag()
    var viewModel: OrderBookViewModel
    var transactionCellViewController: TransactionCellViewController
    
    init(viewModel: OrderBookViewModel, transactionViewModel: TransactionViewModel) {
        self.viewModel = viewModel
        self.transactionCellViewController = TransactionCellViewController(viewModel: transactionViewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(viewModel: OrderBookViewModel) {
        fatalError("init(coder:) has not been implemented")
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
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets.zero)
        }
    }
    
    func bind() {
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
        
        self.viewModel.output.prevClosingPrice
            .bind(to: self.rx.prevClosePrice)
            .disposed(by: disposeBag)
        
        self.viewModel.output.closePrice
            .bind(to: self.rx.closePrice)
            .disposed(by: disposeBag)
    }
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
        let askListIndex = self.askList.count + indexPath.row - 30
        let bidListIndex = indexPath.row - 30
        
        if indexPath.row == 0 && indexPath.column == 2 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookTickerCell.self), for: indexPath) as? OrderBookTickerCell
            
            cell?.lowPriceLabel.content = "\(self.tickerData.minPrice?.decimal ?? "")\n\(self.tickerData.minPrice?.changeRate(from: self.prevClosePrice) ?? "")"
            cell?.highPriceLabel.content = "\(self.tickerData.maxPrice?.decimal ?? "")\n\(self.tickerData.maxPrice?.changeRate(from: self.prevClosePrice) ?? "")"
            cell?.openPriceLabel.content = self.tickerData.openingPrice?.decimal
            cell?.prevClosePriceLabel.content = self.tickerData.prevClosingPrice?.decimal
            cell?.accTradeValueLabel.content = self.tickerData.accTradeValue24H?.displayToBillions
            #warning("코인 이름에 맞춰 넣어주기")
            if let unitsTraded = self.tickerData.unitsTraded24H?.displayToCoin {
                cell?.unitsTradedLabel.content = unitsTraded + " BTC"
            }
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
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookPriceCell.self), for: indexPath) as? OrderBookPriceCell
            
            if !self.askList.isEmpty && !self.bidList.isEmpty {
                if indexPath.column ==  0 && indexPath.row < 30 {
                    cell?.priceLabel.text = self.askList[askListIndex].quantity?.rounded
                    cell?.priceLabel.textAlignment = .right
                    cell?.contentView.backgroundColor = Color.backgroundBlue
                    cell?.priceLabel.textColor = .black
                }
                
                if indexPath.column ==  1 {
                    if indexPath.row < 30 {
                        cell?.priceLabel.text = self.askList[askListIndex].price?.decimal
                        cell?.percentLabel.text = self.askList[askListIndex].price?.changeRate(from: self.prevClosePrice)
                        cell?.contentView.backgroundColor = Color.backgroundBlue
                        cell?.priceLabel.textColor = self.prevClosePrice <= self.askList[askListIndex].price ?? "" ? .red : .blue
                        cell?.percentLabel.textColor = self.prevClosePrice <= self.askList[askListIndex].price ?? "" ? .red : .blue
                        
                        if self.askList[self.askList.count + indexPath.row - 30].price ?? "" == self.closePrice {
                            cell?.borders.top = .solid(width: 1, color: .black)
                            cell?.borders.left = .solid(width: 1, color: .black)
                            cell?.borders.right = .solid(width: 1, color: .black)
                            cell?.borders.bottom = .solid(width: 1, color: .black)
                        }
                    } else {
                        cell?.priceLabel.text = self.bidList[bidListIndex].price?.decimal
                        cell?.percentLabel.text = self.bidList[bidListIndex].price?.changeRate(from: self.prevClosePrice)
                        cell?.contentView.backgroundColor = Color.backgroundRed
                        cell?.priceLabel.textColor = self.prevClosePrice <= self.bidList[bidListIndex].price ?? "" ? .red : .blue
                        cell?.percentLabel.textColor = self.prevClosePrice <= self.bidList[bidListIndex].price ?? "" ? .red : .blue
                        
                        if self.bidList[indexPath.row - 30].price ?? "" == self.closePrice {
                            cell?.borders.top = .solid(width: 1, color: .black)
                            cell?.borders.left = .solid(width: 1, color: .black)
                            cell?.borders.right = .solid(width: 1, color: .black)
                            cell?.borders.bottom = .solid(width: 1, color: .black)
                        }
                    }
                }
                
                if indexPath.column ==  2 && indexPath.row >= 30 {
                    cell?.priceLabel.text = self.bidList[bidListIndex].quantity?.rounded
                    cell?.priceLabel.textAlignment = .left
                    cell?.contentView.backgroundColor = Color.backgroundRed
                    cell?.priceLabel.textColor = .black
                }
            }
            return cell
        }
    }
}

extension OrderBookViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: "호가")
    }
}
