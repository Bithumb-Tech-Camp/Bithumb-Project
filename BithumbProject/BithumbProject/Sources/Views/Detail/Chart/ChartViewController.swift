//
//  ChartViewController.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/02.
//

import UIKit

import Charts
import RxSwift
import RxViewController
import XLPagerTabStrip

enum ChartLayout: Int {
    case single = 1
    case double = 2
    case triple = 3
    case quad = 4
    case full = 5
}

struct ChartOption: Hashable {
    var orderCurrency: OrderCurrency
    var interval: ChartInterval
    var layout: ChartLayout
}

final class ChartViewController: UIViewController, ViewModelBindable {

    private let chartMenuView: UIView = UIView()
    
    private let chartBackgroundView: UIView = UIView()
    
    private let menuStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    private let optionIntervalStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 1
        $0.backgroundColor = .systemGray5
        $0.layer.borderColor = UIColor.systemGray5.cgColor
        $0.layer.borderWidth = 1
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)

    }
    
    private let optionMinuteIntervalStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 1
        $0.backgroundColor = .systemGray5
        $0.layer.borderColor = UIColor.systemGray5.cgColor
        $0.layer.borderWidth = 1
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    private let optionHourIntervalStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 1
        $0.backgroundColor = .systemGray5
        $0.layer.borderColor = UIColor.systemGray5.cgColor
        $0.layer.borderWidth = 1
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    private let optionIntervalButtons: [UIButton] = [
        ChartInterval.minute(1),
        ChartInterval.hour(1),
        ChartInterval.day
    ].map { option in
        let optionButton = UIButton().then {
            var korean = option.toKorean
            if let first = korean.first, first.isNumber {
                korean.removeFirst()
            }
            $0.tag = option.toTag
            $0.setTitle(korean, for: .normal)
            $0.setTitleColor(.darkGray, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .light)
            $0.backgroundColor = .white
        }
        return optionButton
    }
    
    private let optionMinuteIntervalButtons: [UIButton] = [
        ChartInterval.minute(1),
        ChartInterval.minute(3),
        ChartInterval.minute(5),
        ChartInterval.minute(10),
        ChartInterval.minute(30)
    ].map { option in
        let optionButton = UIButton().then {
            $0.tag = option.toTag
            $0.setTitle(option.toKorean, for: .normal)
            $0.setTitleColor(.darkGray, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
            $0.backgroundColor = .white
        }
        return optionButton
    }
    
    private let optionHourIntervalButtons: [UIButton] = [
        ChartInterval.hour(1),
        ChartInterval.hour(6),
        ChartInterval.hour(12),
        ChartInterval.hour(24)
    ].map { option in
        let optionButton = UIButton().then {
            $0.tag = option.toTag
            $0.setTitle(option.toKorean, for: .normal)
            $0.setTitleColor(.darkGray, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
            $0.backgroundColor = .white
        }
        return optionButton
    }
    
    private let optionLayoutButton: UIButton = UIButton().then {
        $0.setImage(
            UIImage(
                systemName: "rectangle",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
            ),
            for: .normal
        )
        $0.tintColor = .darkGray
        $0.backgroundColor = .systemGray5
    }
    
    private let optionSettingButton: UIButton = UIButton().then {
        $0.setImage(
            UIImage(
                systemName: "gearshape",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
            ),
            for: .normal
        )
        $0.tintColor = .darkGray
        $0.backgroundColor = .systemGray5
    }
    
    var viewModel: ChartViewModel
    var disposeBag: DisposeBag = DisposeBag()
    
    init(viewModel: ChartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chartMenuView.layer.addBorder([.bottom], color: .systemGray, width: 0.7)
    }
    
    private func setupViews() {
        optionIntervalButtons.forEach {
            optionIntervalStackView.addArrangedSubview($0)
        }
        
        optionMinuteIntervalButtons.forEach {
            optionMinuteIntervalStackView.addArrangedSubview($0)
        }
        
        optionHourIntervalButtons.forEach {
            optionHourIntervalStackView.addArrangedSubview($0)
        }
        
        [optionIntervalStackView, optionLayoutButton, optionSettingButton].forEach {
            menuStackView.addArrangedSubview($0)
        }
        
        chartMenuView.addSubview(menuStackView)
        
        view.addSubview(chartMenuView)
        view.addSubview(chartBackgroundView)
        view.addSubview(optionMinuteIntervalStackView)
        view.addSubview(optionHourIntervalStackView)
        
        removeChartView()
        addChartView()
        setupChartView()
        
        optionMinuteIntervalStackView.isHidden = true
        optionHourIntervalStackView.isHidden = true
        
        chartMenuView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(45)
        }
        
        menuStackView.snp.makeConstraints {
            $0.centerY.equalTo(chartMenuView.snp.centerY)
            $0.trailing.equalTo(chartMenuView.snp.trailing).inset(5)
        }
        
        optionMinuteIntervalStackView.snp.makeConstraints {
            $0.top.equalTo(menuStackView.snp.bottom).inset(-5)
        }
        
        optionHourIntervalStackView.snp.makeConstraints {
            $0.top.equalTo(menuStackView.snp.bottom).inset(-5)
        }
        
        optionMinuteIntervalStackView.arrangedSubviews[optionMinuteIntervalButtons.count / 2].snp.makeConstraints {
            $0.centerX.equalTo(optionIntervalStackView.arrangedSubviews[0].snp.centerX)
        }
        
        optionHourIntervalStackView.arrangedSubviews[optionHourIntervalButtons.count / 2].snp.makeConstraints {
            $0.centerX.equalTo(optionIntervalStackView.arrangedSubviews[1].snp.centerX)
        }
        
        optionMinuteIntervalButtons.forEach { button in
            button.snp.makeConstraints {
                $0.height.equalTo(34)
                $0.width.equalTo(34)
            }
        }
        
        optionHourIntervalButtons.forEach { button in
            button.snp.makeConstraints {
                $0.height.equalTo(34)
                $0.width.equalTo(34)
            }
        }
        
        optionIntervalButtons.forEach { button in
            button.snp.makeConstraints {
                $0.height.equalTo(34)
                $0.width.equalTo(34)
            }
        }
        
        optionLayoutButton.snp.makeConstraints {
            $0.width.equalTo(optionLayoutButton.snp.height)
            $0.width.equalTo(35)
        }
        
        optionSettingButton.snp.makeConstraints {
            $0.width.equalTo(optionSettingButton.snp.height)
            $0.width.equalTo(35)
        }
        
        chartBackgroundView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(chartMenuView.snp.bottom)
        }

    }
    
    func bind() {
        
        rx.viewWillAppear
            .bind(onNext: {[weak self] _ in
                self?.viewModel.input.fetchCandlestick.onNext(())
                self?.viewModel.input.fetchRealtimeTicker.onNext(())
            })
            .disposed(by: disposeBag)
        
        optionIntervalButtons.forEach { button in
            button.rx.tap
                .bind(onNext: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    if button.tag / 100 == 1 {
                        self.optionMinuteIntervalStackView.isHidden.toggle()
                        self.optionHourIntervalStackView.isHidden = true
                    } else if button.tag / 100 == 2 {
                        self.optionHourIntervalStackView.isHidden.toggle()
                        self.optionMinuteIntervalStackView.isHidden = true
                    } else {
                        self.optionHourIntervalStackView.isHidden = true
                        self.optionMinuteIntervalStackView.isHidden = true
                        guard let newInterval = ChartInterval(tag: button.tag) else {
                            return
                        }
                        let option = ChartOption(
                            orderCurrency: self.viewModel.output.option.value.orderCurrency,
                            interval: newInterval,
                            layout: self.viewModel.output.option.value.layout
                        )
                        self.viewModel.input.changeOption.onNext(option)
                    }
                })
                .disposed(by: disposeBag)
        }
        
        optionMinuteIntervalButtons.enumerated().forEach { index, button in
            button.rx.tap
                .bind(onNext: { [weak self] in
                    guard let self = self, let newInterval = ChartInterval(tag: self.optionMinuteIntervalButtons[index].tag) else {
                        return
                    }
                    let option = ChartOption(
                        orderCurrency: self.viewModel.output.option.value.orderCurrency,
                        interval: newInterval,
                        layout: self.viewModel.output.option.value.layout
                    )
                    self.viewModel.input.changeOption.onNext(option)
                    self.optionHourIntervalStackView.isHidden = true
                    self.optionMinuteIntervalStackView.isHidden = true
                })
                .disposed(by: disposeBag)
        }
        
        optionHourIntervalButtons.enumerated().forEach { index, button in
            button.rx.tap
                .bind(onNext: { [weak self] in
                    guard let self = self, let newInterval = ChartInterval(tag: self.optionHourIntervalButtons[index].tag) else {
                        return
                    }
                    let option = ChartOption(
                        orderCurrency: self.viewModel.output.option.value.orderCurrency,
                        interval: newInterval,
                        layout: self.viewModel.output.option.value.layout
                    )
                    self.viewModel.input.changeOption.onNext(option)
                    self.optionHourIntervalStackView.isHidden = true
                    self.optionMinuteIntervalStackView.isHidden = true
                })
                .disposed(by: disposeBag)
        }
        
        viewModel.output
            .option
            .subscribe(onNext: {[weak self] option in
                guard let self = self else {
                    return
                }
                self.optionIntervalStackView.arrangedSubviews.forEach { button in
                    guard let button = button as? UIButton else {
                        return
                    }
                    let isSelected = button.tag / 100 == option.interval.toTag / 100
                    self.updateOptionIntervalButton(button: button, isSelected: isSelected)
                }
                
                (self.optionMinuteIntervalStackView.arrangedSubviews +
                 self.optionHourIntervalStackView.arrangedSubviews).forEach { button in
                    guard let button = button as? UIButton else {
                        return
                    }
                    let isSelected = button.tag == option.interval.toTag
                    self.updateOptionIntervalButton(button: button, isSelected: isSelected)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func removeChartView() {
        chartBackgroundView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    private func addChartView() {
        let currentLayout = self.viewModel.output.option.value.layout
        switch currentLayout {
        case .single:
            let chartView = SingleChartView(viewModel: viewModel)
            chartView.tag = currentLayout.rawValue
            chartBackgroundView.addSubview(chartView)
        default:
            return
        }
    }
    
    private func setupChartView() {
        chartBackgroundView.subviews.forEach {
            $0.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalTo(chartBackgroundView)
            }
        }
    }
    
    private func updateOptionIntervalButton(button: UIButton, isSelected: Bool) {
        if isSelected {
            button.setTitleColor(.orange, for: .normal)
            button.layer.borderColor = UIColor.orange.cgColor
            button.layer.borderWidth = 1.0
        } else {
            button.setTitleColor(.darkGray, for: .normal)
            button.layer.borderColor = UIColor.white.withAlphaComponent(0).cgColor
            button.layer.borderWidth = 1.0
        }
    }
}

extension ChartViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: "차트")
    }
}
