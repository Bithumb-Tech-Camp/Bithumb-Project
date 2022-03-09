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
        $0.xAxis.spaceMax = 50
        
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
        $0.xAxis.spaceMax = 50
        
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
    
    private lazy var candlestickChartDataEntry = self.candlesticks.enumerated().map { index, candlestick in
        CandleChartDataEntry(
            x: Double(index),
            shadowH: candlestick.safeHighPrice,
            shadowL: candlestick.safeLowPrice,
            open: candlestick.safeOpenPrice,
            close: candlestick.safeClosePrice
        )
    }
    
    private lazy var barChartDataEntry = self.candlesticks.enumerated().map { index, candlestick in
        BarChartDataEntry(x: Double(index), y: candlestick.safeTransactionVolume)
    }

    var realtimeTicker: PublishRelay<RealtimeTicker> = PublishRelay<RealtimeTicker>()
    var disposeBag: DisposeBag = DisposeBag()
    private var draggablelineBarViewHeightConstraint: NSLayoutConstraint?
    private let candlesticks: [Candlestick]
    private var candlestickChartDataSet: CandleChartDataSet?
    private var barChartDataSet: BarChartDataSet?
    
    init(candlesticks: [Candlestick], option: ChartOption) {
        self.candlesticks = candlesticks
        super.init(frame: .zero)
        setupViews(candlesticks: candlesticks, option: option)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(candlesticks: [Candlestick], option: ChartOption) {
        
        let candlestickMALineChartDataEntry: (Int, [Candlestick]) -> [ChartDataEntry] = { num, candlesticks in
            if candlesticks.count <= 0 || candlesticks.count < num {
                return []
            }
            return ((num-1)..<candlesticks.count).map { index in
                var total: Double = 0
                for idx in (index-(num-1)...index) {
                    total += candlesticks[idx].safeClosePrice
                }
                return ChartDataEntry(x: Double(index), y: total / Double(num))
            }
        }
        
        let barMALineChartDataEntry: (Int, [Candlestick]) -> [ChartDataEntry] = { num, candlesticks in
            if candlesticks.count <= 0 || candlesticks.count < num  {
                return []
            }
            return ((num-1)..<candlesticks.count).map { index in
                var total: Double = 0
                for idx in (index-(num-1)...index) {
                    total += candlesticks[idx].safeTransactionVolume
                }
                return ChartDataEntry(x: Double(index), y: total / Double(num))
            }
        }
        
        let dataXAxisLabel = candlesticks.compactMap { (candlestick: Candlestick) -> String? in
            let interval = option.interval
            var format: String = "yyyy-MM-dd"
            switch interval {
            case .minute, .hour:
                format = "dd일 HH:mm"
            case .day, .week, .month:
                format = "yyyy-MM-dd"
            }
            return candlestick.standardTime?.date(format: format)
        }
        
        let barChartColors = candlesticks.map { $0.updown.color }
        
        self.candlestickChartDataSet = setupCandlestickDataSet(entries: candlestickChartDataEntry)
        let candlestickMA5LineChartDataSet = setupMA5LineChartDataSet(entries: candlestickMALineChartDataEntry(5, candlesticks))
        let candlestickMA10LineChartDataSet = setupMA10LineChartDataSet(entries: candlestickMALineChartDataEntry(10, candlesticks))
        let candlestickMA20LineChartDataSet = setupMA20LineChartDataSet(entries: candlestickMALineChartDataEntry(20, candlesticks))
        let candlestickMA60LineChartDataSet = setupMA60LineChartDataSet(entries: candlestickMALineChartDataEntry(60, candlesticks))
        let candlestickMA120LineChartDataSet = setupMA120LineChartDataSet(entries: candlestickMALineChartDataEntry(120, candlesticks))
        
        guard let candlestickChartDataSet = self.candlestickChartDataSet else {
            return
        }
        setupTopCombinedChartView(
            candlestickChartDataSet: candlestickChartDataSet,
            candlestickMA5LineChartDataSet: candlestickMA5LineChartDataSet,
            candlestickMA10LineChartDataSet: candlestickMA10LineChartDataSet,
            candlestickMA20LineChartDataSet: candlestickMA20LineChartDataSet,
            candlestickMA60LineChartDataSet: candlestickMA60LineChartDataSet,
            candlestickMA120LineChartDataSet: candlestickMA120LineChartDataSet,
            dataXAxisLabel: dataXAxisLabel
        )
        
        self.barChartDataSet = setupBarDataSet(entries: barChartDataEntry, colors: barChartColors)
        let barMA5LineChartDataSet = setupMA5LineChartDataSet(entries: barMALineChartDataEntry(5, candlesticks))
        let barMA10LineChartDataSet = setupMA10LineChartDataSet(entries: barMALineChartDataEntry(10, candlesticks))
        let barMA20LineChartDataSet = setupMA20LineChartDataSet(entries: barMALineChartDataEntry(20, candlesticks))
        let barMA60LineChartDataSet = setupMA60LineChartDataSet(entries: barMALineChartDataEntry(60, candlesticks))
        let barMA120LineChartDataSet = setupMA120LineChartDataSet(entries: barMALineChartDataEntry(120, candlesticks))
        
        guard let barChartDataSet = self.barChartDataSet else {
            return
        }
        
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
        topCombinedChartView.notifyDataSetChanged()
        bottomCombinedChartView.notifyDataSetChanged()
        
        let recentCandlestick = candlesticks[candlesticks.count - 1]
        renderLimitLineAndLimitLineLabel(
            closePrice: recentCandlestick.safeOpenPrice,
            volume: recentCandlestick.safeTransactionVolume,
            updownColor: recentCandlestick.updown.color
        )
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
                guard let oldCandlestickChartDataEntry = self.candlestickChartDataEntry.popLast(),
                      let oldBarChartDataEntry = self.barChartDataEntry.popLast() else {
                    return
                }
                
                let newCandlestickChartDataEntry = CandleChartDataEntry(
                    x: oldCandlestickChartDataEntry.x,
                    shadowH: realtimeTicker.safeHighPrice,
                    shadowL: realtimeTicker.safeLowPrice,
                    open: realtimeTicker.safeOpenPrice,
                    close: realtimeTicker.safeClosePrice
                )
                self.candlestickChartDataEntry.append(newCandlestickChartDataEntry)
                self.candlestickChartDataSet?.replaceEntries(self.candlestickChartDataEntry)
                
                let newBarChartDataEntry = BarChartDataEntry(x: oldBarChartDataEntry.x, y: realtimeTicker.safeVolume)
                self.barChartDataEntry.append(newBarChartDataEntry)
                self.barChartDataSet?.replaceEntries(self.barChartDataEntry)
                if var colors = self.barChartDataSet?.colors, !colors.isEmpty {
                    colors.removeLast()
                    colors.append(realtimeTicker.updown.color)
                    self.barChartDataSet?.colors = colors
                }
                
                self.renderLimitLineAndLimitLineLabel(
                    closePrice: realtimeTicker.safeClosePrice,
                    volume: realtimeTicker.safeVolume,
                    updownColor: realtimeTicker.updown.color
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func renderLimitLineAndLimitLineLabel(
        closePrice: Double,
        volume: Double,
        updownColor: UIColor
    ) {
        
        let closePriceLine = ChartLimitLine(limit: closePrice)
        closePriceLine.lineWidth = 0.5
        closePriceLine.lineColor = updownColor
        
        let volumeLine = ChartLimitLine(limit: volume)
        volumeLine.lineWidth = 0.5
        volumeLine.lineColor = updownColor
        
        self.topCombinedChartView.rightYAxisRenderer = CustomYxisRenderer(
            viewPortHandler: self.topCombinedChartView.rightYAxisRenderer.viewPortHandler,
            yAxis: self.topCombinedChartView.rightAxis,
            transformer: self.topCombinedChartView.getTransformer(forAxis: .right)
        )
        self.bottomCombinedChartView.rightYAxisRenderer = CustomYxisRenderer(
            viewPortHandler: self.bottomCombinedChartView.rightYAxisRenderer.viewPortHandler,
            yAxis: self.bottomCombinedChartView.rightAxis,
            transformer: self.bottomCombinedChartView.getTransformer(forAxis: .right)
        )
        
        if let customYxisRenderer = self.topCombinedChartView.rightYAxisRenderer as? CustomYxisRenderer {
            customYxisRenderer.limitLineLabelRectColor = updownColor
            customYxisRenderer.limitLineLabelText = String(closePrice)
        }
        
        if let customYxisRenderer = self.bottomCombinedChartView.rightYAxisRenderer as? CustomYxisRenderer {
            customYxisRenderer.limitLineLabelRectColor = updownColor
            customYxisRenderer.limitLineLabelText = String(volume)
        }
        
        self.topCombinedChartView.rightAxis.removeAllLimitLines()
        self.topCombinedChartView.rightAxis.addLimitLine(closePriceLine)
        self.topCombinedChartView.notifyDataSetChanged()
        
        self.bottomCombinedChartView.rightAxis.removeAllLimitLines()
        self.bottomCombinedChartView.rightAxis.addLimitLine(volumeLine)
        self.bottomCombinedChartView.notifyDataSetChanged()
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
        dataSet.highlightEnabled = false
        dataSet.barSpace = 0.1
        return dataSet
    }
    
    private func setupBarDataSet(entries: [BarChartDataEntry], colors: [UIColor]) -> BarChartDataSet {
        let dataSet = BarChartDataSet(entries: entries, label: "거래량")
        dataSet.drawValuesEnabled = false
        dataSet.highlightEnabled = false
        dataSet.colors = colors
        return dataSet
    }
    
    private func setupMA5LineChartDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: "5")
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 0.5
        dataSet.colors = [UIColor.magenta]
        dataSet.highlightEnabled = false
        return dataSet
    }
    
    private func setupMA10LineChartDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: "10")
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 0.5
        dataSet.colors = [UIColor.blue]
        dataSet.highlightEnabled = false
        return dataSet
    }
    
    private func setupMA20LineChartDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: "20")
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 0.5
        dataSet.colors = [UIColor.yellow]
        dataSet.highlightEnabled = false
        return dataSet
    }
    
    private func setupMA60LineChartDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: "60")
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 0.5
        dataSet.colors = [UIColor.orange]
        dataSet.highlightEnabled = false
        return dataSet
    }
    
    private func setupMA120LineChartDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: "120")
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 0.5
        dataSet.colors = [UIColor.lightGray]
        dataSet.highlightEnabled = false
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
        topCombinedChartView.notifyDataSetChanged()
        bottomCombinedChartView.notifyDataSetChanged()
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        let currentMatrix = chartView.viewPortHandler.touchMatrix
        topCombinedChartView.viewPortHandler.refresh(newMatrix: currentMatrix, chart: topCombinedChartView, invalidate: true)
        bottomCombinedChartView.viewPortHandler.refresh(newMatrix: currentMatrix, chart: bottomCombinedChartView, invalidate: true)
        topCombinedChartView.notifyDataSetChanged()
        bottomCombinedChartView.notifyDataSetChanged()
    }
}

class CustomYxisRenderer: YAxisRenderer {
    
    public var limitLineLabelRectColor: UIColor = .systemRed
    public var limitLineLabelText: String = "0000"
    
    override func renderLimitLines(context: CGContext) {
        
        guard let yAxis = self.axis as? YAxis, let transformer = self.transformer else {
            return
        }
        
        let limitLines = yAxis.limitLines
        
        if limitLines.count == 0 {
            return
        }
        
        context.saveGState()
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for idx in 0 ..< limitLines.count {
            let limitLine = limitLines[idx]
            
            if !limitLine.isEnabled {
                continue
            }
            
            context.saveGState()
            
            defer {
                context.restoreGState()
            }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.y -= limitLine.lineWidth / 2.0
            clippingRect.size.height += limitLine.lineWidth
            clippingRect.size.width += 60
            
            context.clip(to: clippingRect)
            
            position.x = 0.0
            position.y = CGFloat(limitLine.limit)
            position = position.applying(trans)
            
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position.y))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: position.y))

            context.setStrokeColor(limitLine.lineColor.cgColor)
            context.setLineWidth(limitLine.lineWidth)
            context.strokePath()
            
            context.setLineWidth(0.5)
            context.setFillColor(limitLineLabelRectColor.cgColor)
            context.setStrokeColor(limitLineLabelRectColor.cgColor)
            context.addRect(CGRect(x: viewPortHandler.contentRight, y: position.y - 6, width: 60, height: 12))
            context.drawPath(using: .fillStroke)
            
            ChartUtils.drawText(
                context: context,
                text: limitLineLabelText,
                point: CGPoint(x: viewPortHandler.contentRight + 5, y: position.y - 6),
                align: .left,
                attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.white
                ]
            )
        }
        
        context.restoreGState()
    }
}
