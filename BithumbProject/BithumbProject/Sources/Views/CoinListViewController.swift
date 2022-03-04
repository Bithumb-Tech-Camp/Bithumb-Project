//
//  CoinListViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/02/26.
//

import SafariServices
import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then
import XLPagerTabStrip
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
    
    var viewModel: CoinListViewModel!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeConstraints()
        self.configureNavigationUI()
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
            $0.barHeight = 4
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
    }
    
    private func configureNavigationUI() {
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.titleView = self.coinSearchBar
        self.navigationItem.rightBarButtonItems = [self.alarmBarButton, self.cafeBarButton]
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}
