//
//  CoinDetailViewController.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/02.
//

import UIKit

import RxSwift
import RxViewController
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
        $0.alignment = .center
        $0.distribution = .fillProportionally
        $0.spacing = 15
    }
    
    private let priceStackView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = UIStackView.spacingUseDefault
    }
    
    private lazy var customBackButtonItem: UIBarButtonItem = UIBarButtonItem(
        image: UIImage(
            systemName: "arrow.backward",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        ),
        style: .plain,
        target: self,
        action: #selector(touchleftBarButton)
    )
    
    private lazy var starBarButton: StarButton = StarButton(pointSize: 20)
    
    private lazy var kebabMenuBarButton: UIButton = UIButton().then {
        $0.setImage(
            UIImage(
                systemName: "list.bullet",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            ),
            for: .normal
        )
        $0.tintColor = .black
    }
    
    private lazy var rightBarButtonStackView: UIStackView = UIStackView(
        arrangedSubviews: [starBarButton, kebabMenuBarButton]
    ).then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 10
    }
    
    private lazy var titleLabel: UILabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
        $0.text = "비트코인"
    }
    
    private lazy var titleSymbolLabel: UILabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .light)
        $0.textColor = .darkGray
        $0.text = "BTC/KRW"
    }
    
    private lazy var titleStackView: UIStackView = UIStackView(
        arrangedSubviews: [titleLabel, titleSymbolLabel]
    ).then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = UIStackView.spacingUseDefault
    }
    
    private let buttonBarPagerViewController: ButtonBarPagerTabStripViewController
    
    var viewModel: CoinDetailViewModel
    var disposeBag: DisposeBag = DisposeBag()
    
    init(viewModel: CoinDetailViewModel) {
        self.viewModel = viewModel
        self.buttonBarPagerViewController = CoinDetailButtonBarPagerViewController(viewModel: viewModel)
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
        navigationItem.leftBarButtonItem = customBackButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .darkGray
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButtonStackView)
        titleLabel.text = viewModel.coin.krName
        titleSymbolLabel.text = viewModel.coin.symbol
        navigationItem.titleView = titleStackView
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
        view.backgroundColor = .white
        
        closePriceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        changeAmountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(60)
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
         
        let coinName = "\(self.viewModel.coin.acronyms)_\(self.viewModel.coin.currency.rawValue)"
        let stars = CommonUserDefault<String>.fetch(.star(coinName))
        self.starBarButton.setState(stars.contains(where: { $0 == coinName }))
    }
    
    func bind() {
        
        rx.viewWillAppear
            .subscribe(onNext: { _ in
                self.viewModel.input.fetchTicker.onNext(())
                self.viewModel.input.fetchRealtimeTicker.onNext(())
            })
            .disposed(by: disposeBag)
        
        starBarButton.rx.tap
            .bind { [weak self] in
                let isSelected = self?.starBarButton.isActivated ?? false
                self?.viewModel.coin.star(isSelected)
            }
            .disposed(by: disposeBag)
        
        viewModel.output
            .closePriceText
            .bind(onNext: { [weak self] in
                self?.closePriceLabel.rx.text.onNext($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .changeAmountText
            .bind(onNext: { [weak self] in
                self?.changeAmountLabel.rx.text.onNext($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .changeRateText
            .bind(onNext: { [weak self] in
                self?.changeRateLabel.rx.text.onNext($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .upDown
            .bind(onNext: { [weak self] in
                let color: UIColor = $0 == .up ? .systemRed : .systemBlue
                self?.closePriceLabel.textColor = color
                self?.changeAmountLabel.textColor = color
                self?.changeRateLabel.textColor = color
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .realtimeClosePriceText
            .bind(onNext: { [weak self] in
                self?.closePriceLabel.rx.text.onNext($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .realtimeChangeAmountText
            .bind(onNext: { [weak self] in
                self?.changeAmountLabel.rx.text.onNext($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .realtimeChangeRateText
            .bind(onNext: { [weak self] in
                self?.changeRateLabel.rx.text.onNext($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .realtimeUpDown
            .bind(onNext: { [weak self] in
                let color: UIColor = $0 == .up ? .systemRed : .systemBlue
                self?.closePriceLabel.textColor = color
                self?.changeAmountLabel.textColor = color
                self?.changeRateLabel.textColor = color
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func touchleftBarButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
