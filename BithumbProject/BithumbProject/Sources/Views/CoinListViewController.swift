//
//  CoinListViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/26.
//

import SafariServices
import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import SpreadsheetView
import Then

#warning("Constant 관리 필요")
final class CoinListViewController: UIViewController, ViewModelBindable {
    
    // MARK: - View Properties
    private lazy var coinSearchBar = UISearchBar().then {
        $0.placeholder = "코인명 또는 심볼 검색"
        $0.keyboardType = .webSearch
        $0.searchTextField.backgroundColor = .systemBackground
        $0.addDoneButtonOnKeyboard()
    }
    
    private let cafeBarButton = UIBarButtonItem().then {
        $0.image = UIImage(systemName: "gift")
        $0.tintColor = .black
    }
    
    private let alarmBarButton = UIBarButtonItem().then {
        $0.image = UIImage(systemName: "bell")
        $0.tintColor = .black
    }
    
    private let coinSpreadsheetView = SpreadsheetView().then {
        $0.register(TitleCell.self, forCellWithReuseIdentifier: String(describing: TitleCell.self))
        $0.register(CoinCell.self, forCellWithReuseIdentifier: String(describing: CoinCell.self))
        $0.register(TickerCell.self, forCellWithReuseIdentifier: String(describing: TickerCell.self))
        $0.register(ChangeRateCell.self, forCellWithReuseIdentifier: String(describing: ChangeRateCell.self))
        $0.register(TransactionCell.self, forCellWithReuseIdentifier: String(describing: TransactionCell.self))
        $0.register(StarCell.self, forCellWithReuseIdentifier: String(describing: StarCell.self))
    }
    
    var viewModel: CoinListViewModel!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeConstraints()
        self.configureNavigationUI()
        self.configureSpreadsheet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.coinSpreadsheetView.flashScrollIndicators()
    }
    
    // MARK: - CoinListViewController Bind
    func bindViewModel() {
        
        // output
        
        // input
        self.cafeBarButton.rx.tap
            .bind(onNext: {
                guard let url = URL(string: Constant.URL.cafeURL) else { return }
                let safariViewController = SFSafariViewController(url: url)
                self.present(safariViewController, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        self.alarmBarButton.rx.tap
            .bind(onNext: {
                self.alertMessage(message: "알림으로 가는 탭")
            })
            .disposed(by: self.disposeBag)
        
        self.coinSearchBar.rx.text.orEmpty
            .bind(to: self.viewModel.input.inputQuery)
            .disposed(by: self.disposeBag)
        
        self.coinSearchBar.rx.searchButtonClicked
            .bind(to: self.viewModel.input.searchButtonClicked)
            .disposed(by: self.disposeBag)
    }
    
    private func makeConstraints() {
        var buttonBarController = ButtonBarController().then {
            $0.barColor = .black
            $0.barHeight = 3
            $0.titleDefaultColor = .systemGray
            $0.titleDefaultFont = .systemFont(ofSize: 17, weight: .semibold)
            $0.titleSelectedColor = .black
            $0.titleSelectedFont = .systemFont(ofSize: 17, weight: .semibold)
        }
        buttonBarController.bind(viewModel: self.viewModel)
        buttonBarController.view.isUserInteractionEnabled = true
        self.addChild(buttonBarController)
        self.view.addSubview(buttonBarController.view)
        buttonBarController.view.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
        buttonBarController.didMove(toParent: self)
        
        self.view.addSubview(self.coinSpreadsheetView)
        self.coinSpreadsheetView.snp.makeConstraints { make in
            make.top.equalTo(buttonBarController.view.snp.bottom)
            make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func configureSpreadsheet() {
        self.coinSpreadsheetView.dataSource = self
        self.coinSpreadsheetView.delegate = self
        self.coinSpreadsheetView.stickyRowHeader = true
        self.coinSpreadsheetView.gridStyle = .none
        self.coinSpreadsheetView.intercellSpacing = CGSize(width: 0, height: 0)
    }
    
    private func configureNavigationUI() {
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.titleView = self.coinSearchBar
        self.navigationItem.rightBarButtonItems = [self.alarmBarButton, self.cafeBarButton]
    }
}

extension CoinListViewController: SpreadsheetViewDataSource {
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(
                withReuseIdentifier: String(describing: TitleCell.self),
                for: indexPath) as? TitleCell
            
            let target = self.viewModel.output.headerList[indexPath.column]
            cell?.sortTypeLabel.text = target.name + target.sorting.symbol
            cell?.borders.top = .none
            cell?.borders.left = .none
            cell?.borders.right = .none
            cell?.borders.bottom = .solid(width: 1, color: .systemGray4)
            
            if indexPath.column != 0 {
                cell?.sortTypeLabel.textAlignment = .right
            }
            
            if indexPath.column == 4 {
                cell?.sortTypeLabel.text = nil
                cell?.sortTypeLabel.textAlignment = .center
            }
            
            return cell
        } else if indexPath.column == 0 {
            let cell = spreadsheetView.dequeueReusableCell(
                withReuseIdentifier: String(describing: CoinCell.self),
                for: indexPath) as? CoinCell
            
            cell?.borders.top = .none
            cell?.borders.left = .none
            cell?.borders.right = .none
            cell?.borders.bottom = .solid(width: 1, color: .systemGray6)
            
            return cell
        } else if indexPath.column == 1 {
            let cell = spreadsheetView.dequeueReusableCell(
                withReuseIdentifier: String(describing: TickerCell.self),
                for: indexPath) as? TickerCell
            
            cell?.borders.top = .none
            cell?.borders.left = .none
            cell?.borders.right = .none
            cell?.borders.bottom = .solid(width: 1, color: .systemGray6)

            return cell
        } else if indexPath.column == 2 {
            let cell = spreadsheetView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ChangeRateCell.self),
                for: indexPath) as? ChangeRateCell

            cell?.borders.top = .none
            cell?.borders.left = .none
            cell?.borders.right = .none
            cell?.borders.bottom = .solid(width: 1, color: .systemGray6)

            return cell
        } else if indexPath.column == 3 {
            let cell = spreadsheetView.dequeueReusableCell(
                withReuseIdentifier: String(describing: TransactionCell.self),
                for: indexPath) as? TransactionCell
            
            cell?.borders.top = .none
            cell?.borders.left = .none
            cell?.borders.right = .none
            cell?.borders.bottom = .solid(width: 1, color: .systemGray6)

            return cell
        } else if indexPath.column == 4 {
            let cell = spreadsheetView.dequeueReusableCell(
                withReuseIdentifier: String(describing: StarCell.self),
                for: indexPath) as? StarCell
            
            cell?.borders.top = .none
            cell?.borders.left = .none
            cell?.borders.right = .none
            cell?.borders.bottom = .solid(width: 1, color: .systemGray6)

            return cell
        }
        return nil
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        let headerHeight: CGFloat = 40
        let rowHeight: CGFloat = 50
        if row == 0 {
            return headerHeight
        } else {
            return rowHeight
        }
        
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        let margin: CGFloat = 5
        let wholeWidth: CGFloat = self.coinSpreadsheetView.frame.width
        let firstColumnWidth: CGFloat = wholeWidth / 4.5
        let secondColumnWidth: CGFloat = wholeWidth / 4.5
        let thirdColumnWidth: CGFloat = wholeWidth / 5.0
        let fifthColumnWidth: CGFloat = wholeWidth / 8.5
        let fourthColumnWidth: CGFloat = wholeWidth - firstColumnWidth - secondColumnWidth - thirdColumnWidth - fifthColumnWidth - (margin)
        
        switch column {
        case 0:
            return firstColumnWidth
        case 1:
            return secondColumnWidth
        case 2:
            return thirdColumnWidth
        case 3:
            return fourthColumnWidth
        case 4:
            return fifthColumnWidth
        default:
            return 0
        }
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 5
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 20
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
}

extension CoinListViewController: SpreadsheetViewDelegate {
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            var target = self.viewModel.output.headerList[indexPath.column]
            if target.column == indexPath.column {
                target.toggling(indexPath.column)
                print(target.sorting.symbol)
            } else {
                target = SortedColumn(column: indexPath.row, sorting: .ascending)
            }
            
            self.coinSpreadsheetView.reloadData()
        }
    }
}
