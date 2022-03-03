//
//  CoinListViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/26.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then
import XLPagerTabStrip

class CoinListViewController: UIViewController, ViewModelBindable {
    
    // MARK: - View Properties
    private lazy var coinSearchBar = UISearchBar().then {
        $0.placeholder = "코인명 또는 심볼 검색"
        $0.keyboardType = .webSearch
        $0.searchTextField.backgroundColor = .systemBackground
        $0.addDoneButtonOnKeyboard()
    }
    
#warning("Constant 관리 및 다크모드 대응 Color 제작 필요")
    private let cafeBarButton = UIBarButtonItem().then {
        $0.image = UIImage(systemName: "gift")
        $0.tintColor = .black
    }
    
    private let alarmBarButton = UIBarButtonItem().then {
        $0.image = UIImage(systemName: "bell")
        $0.tintColor = .black
    }
    
    private var coinListButtonBarPagerViewController = CoinListButtonBarPagerViewController()
    
    var viewModel: CoinListViewModel!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupNavigation()
    }
    
    // MARK: - CoinListViewController Bind
    func bindViewModel() {
        
    }
    
    private func setupViews() {
        self.coinListButtonBarPagerViewController.bind(viewModel: self.viewModel)
        self.view.addSubview(self.coinListButtonBarPagerViewController.view)
        self.coinListButtonBarPagerViewController.view.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setupNavigation() {
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.titleView = self.coinSearchBar
        self.navigationItem.rightBarButtonItems = [self.cafeBarButton, self.alarmBarButton]
    }
}
