//
//  SingleChartView.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/04.
//

import UIKit

import Charts
import RxSwift
import RxCocoa
import RxGesture

final class SingleChartView: UIView {
    
    lazy var topCombinedChartView: CombinedChartView = CombinedChartView().then {
        $0.delegate = self
        
        $0.scaleYEnabled = false
        $0.scaleXEnabled = true
        
        $0.legend.horizontalAlignment = .left
        $0.legend.verticalAlignment = .top
        $0.legend.drawInside = true
        
        $0.xAxis.labelPosition = .bottom
        $0.xAxis.labelHeight = 5
        $0.xAxis.axisMaxLabels = 3
        $0.xAxis.gridLineWidth = 0.5
        $0.xAxis.gridColor = .systemGray5
        $0.xAxis.labelTextColor = UIColor.darkGray
        $0.xAxis.axisLineColor = UIColor.white.withAlphaComponent(0.0)
        $0.xAxis.setLabelCount(3, force: false)
        $0.xAxis.spaceMin = 0.5
        $0.xAxis.spaceMax = 100
        
        $0.rightAxis.enabled = true
        $0.rightAxis.minWidth = 60
        $0.rightAxis.maxWidth = 60
        $0.rightAxis.gridLineWidth = 0.5
        $0.rightAxis.gridColor = .systemGray5
        $0.rightAxis.axisLineColor = .systemGray5
        $0.rightAxis.labelTextColor = UIColor.darkGray
        
        $0.leftAxis.enabled = false
        $0.minOffset = 0
        $0.chartDescription?.enabled = false
        $0.autoScaleMinMaxEnabled = true
    }
    
    lazy var bottomCombinedChartView: CombinedChartView = CombinedChartView().then {
        $0.delegate = self
        
        $0.scaleYEnabled = false
        $0.scaleXEnabled = true
        
        $0.legend.enabled = false
        
        $0.xAxis.labelHeight = 0
        $0.xAxis.labelTextColor = UIColor.white.withAlphaComponent(0.0)
        $0.xAxis.axisMaxLabels = 3
        $0.xAxis.axisLineColor = UIColor.white.withAlphaComponent(0.0)
        $0.xAxis.gridLineWidth = 0.5
        $0.xAxis.gridColor = .systemGray5
        $0.xAxis.spaceMin = 0.5
        $0.xAxis.spaceMax = 100
        
        $0.rightAxis.enabled = true
        $0.rightAxis.minWidth = 60
        $0.rightAxis.maxWidth = 60
        $0.rightAxis.gridLineWidth = 0.5
        $0.rightAxis.gridColor = .systemGray5
        $0.rightAxis.axisLineColor = .systemGray5
        $0.rightAxis.labelTextColor = UIColor.darkGray
        
        $0.leftAxis.enabled = false
        $0.minOffset = 0
        $0.chartDescription?.enabled = false
        $0.autoScaleMinMaxEnabled = true
    }
    
    private let lineBarView: UIView = UIView().then {
        $0.backgroundColor = .systemGray6
    }
    
    private let draggableLineBarView: UIView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.0)
    }
    
    private let candlestickMALineChartDataEntry: (Int, [Candlestick]) -> [ChartDataEntry] = { num, candlesticks in
        if candlesticks.count <= 0 {
            return []
        }
        return ((num-1)..<candlesticks.count).map { index in
            var total: Double = 0
            for idx in (index-(num-1)...index) {
                total += (Double(candlesticks[idx].closePrice ?? "0") ?? 0)
            }
            return ChartDataEntry(x: Double(index), y: total / Double(num))
        }
    }
    
    private let barMALineChartDataEntry: (Int, [Candlestick]) -> [ChartDataEntry] = { num, candlesticks in
        if candlesticks.count <= 0 {
            return []
        }
        return ((num-1)..<candlesticks.count).map { index in
            var total: Double = 0
            for idx in (index-(num-1)...index) {
                total += (Double(candlesticks[idx].transactionVolume ?? "0") ?? 0)
            }
            return ChartDataEntry(x: Double(index), y: total / Double(num))
        }
    }
    
    private var draggablelineBarViewHeightConstraint: NSLayoutConstraint?
    var realtimeTicker: PublishRelay<RealtimeTicker> = PublishRelay<RealtimeTicker>()
    var disposeBag: DisposeBag = DisposeBag()
    
    init(candlesticks: [Candlestick]) {
        super.init(frame: .zero)
        setupViews(candlesticks: candlesticks)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupViews(candlesticks: [Candlestick]) {
        
        let candlestickChartDataEntry = candlesticks.enumerated().map { index, candlestick in
            CandleChartDataEntry(
                x: Double(index),
                shadowH: Double(candlestick.highPrice ?? "0") ?? 0,
                shadowL: Double(candlestick.lowPrice ?? "0") ?? 0,
                open: Double(candlestick.openPrice ?? "0") ?? 0,
                close: Double(candlestick.closePrice ?? "0") ?? 0
            )
        }
        
        let barChartDataEntry = candlesticks.enumerated().map { index, candlestick in
            BarChartDataEntry(x: Double(index), y: Double(candlestick.transactionVolume ?? "0") ?? 0)
        }
        
        let dataXAxisLabel = candlesticks.compactMap {
            $0.standardTime?.date()
        }
        
        let barChartColors = candlesticks.map {
            Double($0.openPrice ?? "0") ?? 0 > Double($0.closePrice ?? "0") ?? 0 ? UIColor.systemBlue : UIColor.systemRed
        }
        
        let candlestickChartDataSet = setupCandlestickDataSet(entries: candlestickChartDataEntry)
        let candlestickMA5LineChartDataSet = setupMA5LineChartDataSet(entries: candlestickMALineChartDataEntry(5, candlesticks))
        let candlestickMA10LineChartDataSet = setupMA10LineChartDataSet(entries: candlestickMALineChartDataEntry(10, candlesticks))
        let candlestickMA20LineChartDataSet = setupMA20LineChartDataSet(entries: candlestickMALineChartDataEntry(20, candlesticks))
        let candlestickMA60LineChartDataSet = setupMA60LineChartDataSet(entries: candlestickMALineChartDataEntry(60, candlesticks))
        let candlestickMA120LineChartDataSet = setupMA120LineChartDataSet(entries: candlestickMALineChartDataEntry(120, candlesticks))
        
        setupTopCombinedChartView(
            candlestickChartDataSet: candlestickChartDataSet,
            candlestickMA5LineChartDataSet: candlestickMA5LineChartDataSet,
            candlestickMA10LineChartDataSet: candlestickMA10LineChartDataSet,
            candlestickMA20LineChartDataSet: candlestickMA20LineChartDataSet,
            candlestickMA60LineChartDataSet: candlestickMA60LineChartDataSet,
            candlestickMA120LineChartDataSet: candlestickMA120LineChartDataSet,
            dataXAxisLabel: dataXAxisLabel
        )
        
        let barChartDataSet = setupBarDataSet(entries: barChartDataEntry, colors: barChartColors)
        let barMA5LineChartDataSet = setupMA5LineChartDataSet(entries: barMALineChartDataEntry(5, candlesticks))
        let barMA10LineChartDataSet = setupMA10LineChartDataSet(entries: barMALineChartDataEntry(10, candlesticks))
        let barMA20LineChartDataSet = setupMA20LineChartDataSet(entries: barMALineChartDataEntry(20, candlesticks))
        let barMA60LineChartDataSet = setupMA60LineChartDataSet(entries: barMALineChartDataEntry(60, candlesticks))
        let barMA120LineChartDataSet = setupMA120LineChartDataSet(entries: barMALineChartDataEntry(120, candlesticks))
        
        setupBottomCombinedChartView(
            barChartDataSet: barChartDataSet,
            barMA5LineChartDataSet: barMA5LineChartDataSet,
            barMA10LineChartDataSet: barMA10LineChartDataSet,
            barMA20LineChartDataSet: barMA20LineChartDataSet,
            barMA60LineChartDataSet: barMA60LineChartDataSet,
            barMA120LineChartDataSet: barMA120LineChartDataSet
        )
        
        addSubview(lineBarView)
        addSubview(topCombinedChartView)
        addSubview(draggableLineBarView)
        addSubview(bottomCombinedChartView)
        
        draggablelineBarViewHeightConstraint = topCombinedChartView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
        draggablelineBarViewHeightConstraint?.priority = .init(rawValue: 100)
        draggablelineBarViewHeightConstraint?.isActive = true
        
        draggableLineBarView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self)
            $0.top.greaterThanOrEqualTo(self.snp.top).inset(50)
            $0.bottom.lessThanOrEqualTo(self.snp.bottom).inset(50)
            $0.height.equalTo(12)
        }
        
        lineBarView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalTo(draggableLineBarView)
        }
        
        topCombinedChartView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(self)
            $0.bottom.equalTo(lineBarView.snp.bottom)
        }
        
        bottomCombinedChartView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self)
            $0.top.equalTo(topCombinedChartView.snp.bottom)
        }
        
        topCombinedChartView.moveViewToX(Double(candlestickChartDataEntry.count - 1))
        bottomCombinedChartView.moveViewToX(Double(barChartDataEntry.count - 1))
        updateTopCombinedChartView()
        updateBottomCombinedChartView()
    }
    
    private func setupBindings() {
        
        var multiplier: CGFloat = 0.5
        
        draggableLineBarView.rx
            .panGesture(configuration: .none)
            .when(.changed)
            .asTranslation()
            .subscribe(onNext: { [weak self] transition, _ in
                guard let self = self else {
                    return
                }
                self.draggablelineBarViewHeightConstraint?.isActive = false
                self.draggablelineBarViewHeightConstraint = self.topCombinedChartView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: multiplier, constant: transition.y)
                self.draggablelineBarViewHeightConstraint?.priority = .init(rawValue: 100)
                self.draggablelineBarViewHeightConstraint?.isActive = true
                self.draggableLineBarView.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        draggableLineBarView.rx
            .panGesture(configuration: .none)
            .when(.ended)
            .subscribe(onNext: { _ in
                multiplier = self.topCombinedChartView.frame.height / self.frame.height
            })
            .disposed(by: disposeBag)
        
        realtimeTicker
            .subscribe(onNext: { realtimeTicker in
                
            })
            .disposed(by: disposeBag)
    }
    
    private func updateTopCombinedChartView() {
        DispatchQueue.main.async {
            self.topCombinedChartView.notifyDataSetChanged()
        }
    }
    
    private func updateBottomCombinedChartView() {
        DispatchQueue.main.async {
            self.bottomCombinedChartView.notifyDataSetChanged()
        }
    }
}

extension SingleChartView {
    
    private func setupCandlestickDataSet(entries: [CandleChartDataEntry]) -> CandleChartDataSet {
        let dataSet = CandleChartDataSet(entries: entries, label: "가격")
        dataSet.decreasingColor = .systemBlue
        dataSet.decreasingFilled = true
        dataSet.increasingColor = .systemRed
        dataSet.increasingFilled = true
        dataSet.neutralColor = .red
        dataSet.shadowWidth = 1.0
        dataSet.shadowColorSameAsCandle = true
        dataSet.drawValuesEnabled = false
        dataSet.highlightColor = .black
        dataSet.barSpace = 0.1
        return dataSet
    }
    
    private func setupBarDataSet(entries: [BarChartDataEntry], colors: [UIColor]) -> BarChartDataSet {
        let dataSet = BarChartDataSet(entries: entries, label: "거래량")
        dataSet.drawValuesEnabled = false
        dataSet.highlightColor = .black
        dataSet.colors = colors
        return dataSet
    }
    
    private func setupMA5LineChartDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: "5")
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.lineWidth = 0.5
        dataSet.colors = [UIColor.magenta]
        return dataSet
    }
    
    private func setupMA10LineChartDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: "10")
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.lineWidth = 0.5
        dataSet.colors = [UIColor.blue]
        return dataSet
    }
    
    private func setupMA20LineChartDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: "20")
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.lineWidth = 0.5
        dataSet.colors = [UIColor.yellow]
        return dataSet
    }
    
    private func setupMA60LineChartDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: "60")
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.lineWidth = 0.5
        dataSet.colors = [UIColor.orange]
        return dataSet
    }
    
    private func setupMA120LineChartDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: "120")
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.lineWidth = 0.5
        dataSet.colors = [UIColor.lightGray]
        return dataSet
    }
    
    // swiftlint:disable all
    private func setupTopCombinedChartView(
        candlestickChartDataSet: CandleChartDataSet,
        candlestickMA5LineChartDataSet: LineChartDataSet,
        candlestickMA10LineChartDataSet: LineChartDataSet,
        candlestickMA20LineChartDataSet: LineChartDataSet,
        candlestickMA60LineChartDataSet: LineChartDataSet,
        candlestickMA120LineChartDataSet: LineChartDataSet,
        dataXAxisLabel: [String]
    ) {
        let combinedChartData = CombinedChartData()
        combinedChartData.candleData = CandleChartData(dataSet: candlestickChartDataSet)
        combinedChartData.lineData = LineChartData(dataSets: [
            candlestickMA5LineChartDataSet,
            candlestickMA10LineChartDataSet,
            candlestickMA20LineChartDataSet,
            candlestickMA60LineChartDataSet,
            candlestickMA120LineChartDataSet
        ])
        
        topCombinedChartView.data = combinedChartData
        topCombinedChartView.setVisibleXRange(minXRange: 20, maxXRange: 365)
        
        topCombinedChartView.xAxis.granularityEnabled = true
        topCombinedChartView.xAxis.granularity = 10
        topCombinedChartView.xAxis.axisMaxLabels = 3
        topCombinedChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataXAxisLabel)
    }
    // swiftlint:enable all
    
    // swiftlint:disable all
    private func setupBottomCombinedChartView(
        barChartDataSet: BarChartDataSet,
        barMA5LineChartDataSet: LineChartDataSet,
        barMA10LineChartDataSet: LineChartDataSet,
        barMA20LineChartDataSet: LineChartDataSet,
        barMA60LineChartDataSet: LineChartDataSet,
        barMA120LineChartDataSet: LineChartDataSet
    ) {
        let combinedChartData = CombinedChartData()
        combinedChartData.barData = BarChartData(dataSet: barChartDataSet)
        combinedChartData.lineData = LineChartData(dataSets: [
            barMA5LineChartDataSet,
            barMA10LineChartDataSet,
            barMA20LineChartDataSet,
            barMA60LineChartDataSet,
            barMA120LineChartDataSet
        ])
        bottomCombinedChartView.data = combinedChartData
        bottomCombinedChartView.setVisibleXRange(minXRange: 20, maxXRange: 365)
        
        bottomCombinedChartView.xAxis.granularityEnabled = true
        bottomCombinedChartView.xAxis.granularity = 10
        bottomCombinedChartView.xAxis.axisMaxLabels = 3
    }
    // swiftlint:enable all
}

extension SingleChartView: ChartViewDelegate {
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        let currentMatrix = chartView.viewPortHandler.touchMatrix
        topCombinedChartView.viewPortHandler.refresh(newMatrix: currentMatrix, chart: topCombinedChartView, invalidate: true)
        bottomCombinedChartView.viewPortHandler.refresh(newMatrix: currentMatrix, chart: bottomCombinedChartView, invalidate: true)
        updateTopCombinedChartView()
        updateBottomCombinedChartView()
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        let currentMatrix = chartView.viewPortHandler.touchMatrix
        topCombinedChartView.viewPortHandler.refresh(newMatrix: currentMatrix, chart: topCombinedChartView, invalidate: true)
        bottomCombinedChartView.viewPortHandler.refresh(newMatrix: currentMatrix, chart: bottomCombinedChartView, invalidate: true)
        updateTopCombinedChartView()
        updateBottomCombinedChartView()
    }
}
