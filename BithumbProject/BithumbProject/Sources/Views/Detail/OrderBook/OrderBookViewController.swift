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
        $0.register(OrderBookQuantityCell.self, forCellWithReuseIdentifier: String(describing: OrderBookQuantityCell.self))
        $0.bounces = false
        $0.showsHorizontalScrollIndicator = false
        $0.intercellSpacing = CGSize(width: 0, height: 0)
        $0.gridStyle = .solid(width: 1, color: .white)
        $0.contentOffset = CGPoint(x: 0, y: 60 * 30 / 3)
    }
    
    var bidList: [BidAsk] = []
    var askList: [BidAsk] = []
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
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
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
        return self.spreadSheetView.frame.width / 3
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
        let maxAsk = self.askList.map { Double($0.quantity ?? "") ?? 0.0 }.max() ?? 0.0
        let maxBid = self.bidList.map { Double($0.quantity ?? "") ?? 0.0 }.max() ?? 0.0
        
        if indexPath.row == 0 && indexPath.column == 2 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookTickerCell.self), for: indexPath) as? OrderBookTickerCell
            
            cell?.lowPriceLabel.content = self.tickerData.minPriceWithPercent(by: self.prevClosePrice)
            cell?.highPriceLabel.content = self.tickerData.maxPriceWithPercent(by: self.prevClosePrice)
            cell?.openPriceLabel.content = self.tickerData.openingPrice?.decimal
            cell?.prevClosePriceLabel.content = self.tickerData.prevClosingPrice?.decimal
            cell?.accTradeValueLabel.content = self.tickerData.accTradeValue24H?.displayToBillions
            cell?.unitsTradedLabel.content = self.tickerData.formattedUnitTraded(with: self.viewModel.coin.acronyms)
            
            return cell
        } else if indexPath.row == 30 && indexPath.column == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookTransactionCell.self), for: indexPath)
            
            cell.layoutIfNeeded()
            if self.children.isEmpty {
                transactionCellViewController.setup(to: self)
            }
            transactionCellViewController.attach(to: cell.contentView)
            
            return cell
        } else if indexPath.column == 0 && indexPath.row < 30 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookQuantityCell.self), for: indexPath) as? OrderBookQuantityCell
            
            if self.askList.isNotEmpty {
                let ask = self.askList[askListIndex]
                cell?.quantityLabel.text = ask.quantity?.roundedDecimal
                cell?.quantityLabel.textAlignment = .right
                cell?.contentView.backgroundColor = Color.backgroundBlue
                cell?.quantityBar.backgroundColor = Color.barBlue
                
                let width: CGFloat = CGFloat(ask.quantity?.quantityPercent(by: maxAsk) ?? 0.0)
                
                cell?.quantityBar.snp.remakeConstraints {
                    $0.centerY.equalToSuperview()
                    $0.trailing.equalToSuperview()
                    $0.width.equalToSuperview().multipliedBy(width)
                    $0.height.equalTo(10)
                }
            }
            
            return cell
        } else if indexPath.column == 2 && indexPath.row >= 30 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookQuantityCell.self), for: indexPath) as? OrderBookQuantityCell
            
            if self.bidList.isNotEmpty {
                let bid = self.bidList[bidListIndex]
                cell?.quantityLabel.text = bid.quantity?.roundedDecimal
                cell?.quantityLabel.textAlignment = .left
                cell?.contentView.backgroundColor = Color.backgroundRed
                cell?.quantityBar.backgroundColor = Color.barRed
                
                let width: CGFloat = CGFloat(bid.quantity?.quantityPercent(by: maxBid) ?? 0.0)
                
                cell?.quantityBar.snp.remakeConstraints {
                    $0.centerY.equalToSuperview()
                    $0.leading.equalToSuperview()
                    $0.width.equalToSuperview().multipliedBy(width)
                    $0.height.equalTo(10)
                }
            }
            return cell
        } else if indexPath.row < 30 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookPriceCell.self), for: indexPath) as? OrderBookPriceCell
            
            if self.askList.isNotEmpty {
                let ask = self.askList[askListIndex]
                cell?.priceLabel.text = ask.price?.decimal
                cell?.percentLabel.text = ask.price?.changeRate(from: self.prevClosePrice)
                cell?.contentView.backgroundColor = Color.backgroundBlue
                cell?.priceLabel.textColor = Double(self.prevClosePrice) ?? 0.0 <= ask.doubleTypePrice ? .systemRed : .systemBlue
                cell?.percentLabel.textColor = Double(self.prevClosePrice) ?? 0.0 <= ask.doubleTypePrice ? .systemRed : .systemBlue
                
                if ask.price ?? "" == self.closePrice {
                    cell?.borders.top = .solid(width: 1, color: .black)
                    cell?.borders.left = .solid(width: 1, color: .black)
                    cell?.borders.right = .solid(width: 1, color: .black)
                    cell?.borders.bottom = .solid(width: 1, color: .black)
                } else {
                    cell?.borders.top = .none
                    cell?.borders.left = .none
                    cell?.borders.right = .none
                    cell?.borders.bottom = .none
                }
            }
            
            return cell
        } else if indexPath.row >= 30 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookPriceCell.self), for: indexPath) as? OrderBookPriceCell
            if self.bidList.isNotEmpty {
                let bid = self.bidList[bidListIndex]
                cell?.priceLabel.text = bid.price?.decimal
                cell?.percentLabel.text = bid.price?.changeRate(from: self.prevClosePrice)
                cell?.contentView.backgroundColor = Color.backgroundRed
                cell?.priceLabel.textColor = Double(self.prevClosePrice) ?? 0.0 <= bid.doubleTypePrice ? .systemRed : .systemBlue
                cell?.percentLabel.textColor = Double(self.prevClosePrice) ?? 0.0 <= bid.doubleTypePrice ? .systemRed : .systemBlue
                
                if bid.price ?? "" == self.closePrice {
                    cell?.borders.top = .solid(width: 1, color: .black)
                    cell?.borders.left = .solid(width: 1, color: .black)
                    cell?.borders.right = .solid(width: 1, color: .black)
                    cell?.borders.bottom = .solid(width: 1, color: .black)
                } else {
                    cell?.borders.top = .none
                    cell?.borders.left = .none
                    cell?.borders.right = .none
                    cell?.borders.bottom = .none
                }
            }
            return cell
        }
        return nil
    }
}

extension OrderBookViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: "호가")
    }
}
