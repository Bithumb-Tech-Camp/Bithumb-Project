//
//  CoinDetailButtonBarPagerViewController.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/02.
//

import Foundation

import Moya
import Then
import XLPagerTabStrip

final class CoinDetailButtonBarPagerViewController: ButtonBarPagerTabStripViewController {
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let buttonBarPagerView: ButtonBarView = ButtonBarView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let defaultFont: UIFont = .systemFont(ofSize: 14, weight: .light)
    private let defaultTextColor: UIColor = .systemGray
    private let selectedFont: UIFont = .systemFont(ofSize: 14, weight: .medium)
    private let selectedTextColor: UIColor = .black
    private let viewModel: CoinDetailViewModel
    
    init(viewModel: CoinDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.setupViews()
        super.viewDidLoad()
    }
    
    private func setupViews() {
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .black
        settings.style.buttonBarItemFont = self.defaultFont
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = self.defaultTextColor
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        // swiftlint:disable all
        changeCurrentIndexProgressive = { [weak self] (
            oldCell: ButtonBarViewCell?,
            newCell: ButtonBarViewCell?,
            progressPercentage: CGFloat,
            changeCurrentIndex: Bool,
            animated: Bool
        ) -> Void in
            guard changeCurrentIndex == true else {
                return
            }
            oldCell?.label.font = self?.defaultFont
            oldCell?.label.textColor = self?.defaultTextColor
            newCell?.label.font = self?.selectedFont
            newCell?.label.textColor = self?.selectedTextColor
        }
        // swiftlint:enable all
        
        self.buttonBarView = self.buttonBarPagerView
        self.containerView = self.scrollView
        self.containerView.isScrollEnabled = false
        
        self.view.addSubview(self.buttonBarPagerView)
        self.view.addSubview(self.scrollView)
        
        buttonBarPagerView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(buttonBarPagerView.snp.bottom)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let chartViewModel = ChartViewModel(
            coin: viewModel.coin,
            httpManager: viewModel.httpManager,
            webSocketManager: viewModel.webSockerManager,
            realmManager: RealmManager()
        )
        let chartViewController = ChartViewController(viewModel: chartViewModel)
        
        let orderBookViewModel = OrderBookViewModel(
            coin: viewModel.coin,
            httpManager: viewModel.httpManager,
            webSocketManager: viewModel.webSockerManager
        )

        let transactionViewModel = TransactionViewModel(
            coin: viewModel.coin,
            httpManager: viewModel.httpManager,
            webSocketManager: viewModel.webSockerManager
        )

        let orderBookViewController = OrderBookViewController(viewModel: orderBookViewModel, transactionViewModel: transactionViewModel)

        let transactionViewController = TransactionViewController(viewModel: transactionViewModel)

        return [
            orderBookViewController,
            chartViewController,
            transactionViewController
        ]
    }
}
