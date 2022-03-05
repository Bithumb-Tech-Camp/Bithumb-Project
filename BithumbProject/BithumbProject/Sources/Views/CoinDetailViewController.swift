//
//  CoinDetailViewController.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/02.
//

import UIKit

import RxSwift
import SnapKit
import Then
import XLPagerTabStrip

final class CoinDetailViewController: UIViewController, ViewModelBindable {
    
    private let headerView: UIView = UIView()
    
    private let closePriceLabel: UILabel = UILabel().then {
        $0.text = "53,026,000"
        $0.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        $0.textColor = .systemRed
    }
    
    private let changeAmountLabel: UILabel = UILabel().then {
        $0.text = "+88000"
        $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        $0.textColor = .systemRed
    }
    
    private let changeRateLabel: UILabel = UILabel().then {
        $0.text = "▲ 0.16%"
        $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        $0.textColor = .systemRed
    }
    
    private let changeLabelStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.distribution = .fill
        $0.spacing = UIStackView.spacingUseDefault
    }
    
    private let priceStackView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = UIStackView.spacingUseDefault
    }
    
    private let buttonBarPagerViewController: ButtonBarPagerTabStripViewController = CoinDetailButtonBarPagerViewController()
    
    var viewModel: CoinDetailViewModel
    var disposeBag: DisposeBag = DisposeBag()
    
    init(viewModel: CoinDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupViews()
        self.bind()
    }
    
    private func setupNavigationBar() {
        
    }
    
    private func setupViews() {
        [changeAmountLabel, changeRateLabel].forEach {
            changeLabelStackView.addArrangedSubview($0)
        }
        
        [closePriceLabel, changeLabelStackView].forEach {
            priceStackView.addArrangedSubview($0)
        }
        
        headerView.addSubview(priceStackView)
        
        view.addSubview(headerView)
        view.addSubview(buttonBarPagerViewController.view)
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(100)
        }
        
        priceStackView.snp.makeConstraints {
            $0.leading.equalTo(10)
            $0.centerY.equalTo(headerView)
        }
        
        buttonBarPagerViewController.view.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func bind() {
        
    }
}
