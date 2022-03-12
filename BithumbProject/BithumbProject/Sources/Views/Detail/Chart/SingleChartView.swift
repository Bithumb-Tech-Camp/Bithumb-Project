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

final class SingleChartView: UIView, ViewModelBindable {
    
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

    var viewModel: ChartViewModel
    var disposeBag: DisposeBag = DisposeBag()
    private var draggablelineBarViewHeightConstraint: NSLayoutConstraint?
    private var multiplier: CGFloat = 0.5
    
    init(viewModel: ChartViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupViews()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
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
    }
    
    func bind() {
        
        draggableLineBarView.rx
            .panGesture(configuration: .none)
            .when(.changed)
            .asTranslation()
            .subscribe(onNext: { [weak self] transition, _ in
                guard let self = self else { return }
                self.draggablelineBarViewHeightConstraint?.isActive = false
                self.draggablelineBarViewHeightConstraint = self.topCombinedChartView.heightAnchor.constraint(
                    equalTo: self.heightAnchor,
                    multiplier: self.multiplier,
                    constant: transition.y
                )
                self.draggablelineBarViewHeightConstraint?.priority = .init(rawValue: 100)
                self.draggablelineBarViewHeightConstraint?.isActive = true
                self.draggableLineBarView.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        draggableLineBarView.rx
            .panGesture(configuration: .none)
            .when(.ended)
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else { return }
                self.multiplier = self.topCombinedChartView.frame.height / self.frame.height
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.output.candlesticks,
            viewModel.output.candlestickChartDataSet,
            viewModel.output.candlestickMA5LineChartDataSet,
            viewModel.output.candlestickMA10LineChartDataSet,
            viewModel.output.candlestickMA20LineChartDataSet,
            viewModel.output.candlestickMA60LineChartDataSet,
            viewModel.output.candlestickMA120LineChartDataSet,
            viewModel.output.candlestickXAxisLabel
        )
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .utility))
            .subscribe(onNext: {[weak self] in
                
                guard let self = self, let recentCandlestick = $0.last else { return }
                self.setupTopCombinedChartView(
                    candlestickChartDataSet: $1,
                    candlestickMA5LineChartDataSet: $2,
                    candlestickMA10LineChartDataSet: $3,
                    candlestickMA20LineChartDataSet: $4,
                    candlestickMA60LineChartDataSet: $5,
                    candlestickMA120LineChartDataSet: $6,
                    dataXAxisLabel: $7
                )
                self.renderLimitLineAndLimitLineLabel(
                    closePrice: recentCandlestick.safeOpenPrice,
                    volume: recentCandlestick.safeTransactionVolume,
                    updownColor: recentCandlestick.updown.color
                )
                self.topCombinedChartView.moveViewToX(Double($0.count - 1))
                self.topCombinedChartView.notifyDataSetChanged()
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.output.candlesticks,
            viewModel.output.barChartDataSet,
            viewModel.output.barMA5LineChartDataSet,
            viewModel.output.barMA10LineChartDataSet,
            viewModel.output.barMA20LineChartDataSet,
            viewModel.output.barMA60LineChartDataSet,
            viewModel.output.barMA120LineChartDataSet
        )
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .utility))
            .subscribe(onNext: {[weak self] in
                guard let self = self, let recentCandlestick = $0.last else { return }
                self.setupBottomCombinedChartView(
                    barChartDataSet: $1,
                    barMA5LineChartDataSet: $2,
                    barMA10LineChartDataSet: $3,
                    barMA20LineChartDataSet: $4,
                    barMA60LineChartDataSet: $5,
                    barMA120LineChartDataSet: $6
                )
                self.renderLimitLineAndLimitLineLabel(
                    closePrice: recentCandlestick.safeOpenPrice,
                    volume: recentCandlestick.safeTransactionVolume,
                    updownColor: recentCandlestick.updown.color
                )
                self.bottomCombinedChartView.moveViewToX(Double($0.count - 1))
                self.bottomCombinedChartView.notifyDataSetChanged()
            })
            .disposed(by: disposeBag)
        
        viewModel.output.realtimeTicker
            .withLatestFrom(
                Observable.zip(
                    viewModel.output.candlestickChartDataEntry,
                    viewModel.output.barChartDataEntry
                )
            ) { ($0, $1.0, $1.1) }
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .utility))
            .subscribe(onNext: {[weak self] realtimeTicker, candlestickChartDataEntry, barChartDataEntry in
                var newCandlestickChartDataEntry = candlestickChartDataEntry
                var newBarChartDataEntry = barChartDataEntry
                guard let self = self,
                      let oldRecentCandlestickChartDataEntry = newCandlestickChartDataEntry.popLast(),
                      let oldRecentBarChartDataEntry = newBarChartDataEntry.popLast() else {
                          return
                      }
                let newRecentCandlestickChartDataEntry = CandleChartDataEntry(
                    x: oldRecentCandlestickChartDataEntry.x,
                    shadowH: realtimeTicker.safeHighPrice,
                    shadowL: realtimeTicker.safeLowPrice,
                    open: realtimeTicker.safeOpenPrice,
                    close: realtimeTicker.safeClosePrice
                )
                let newRecentBarChartDataEntry = BarChartDataEntry(x: oldRecentBarChartDataEntry.x, y: realtimeTicker.safeVolume)
                
                newCandlestickChartDataEntry.append(newRecentCandlestickChartDataEntry)
                newBarChartDataEntry.append(newRecentBarChartDataEntry)
                
                if let candlestickChartDataSet = self.topCombinedChartView.candleData?.getDataSetByIndex(0) as? ChartDataSet,
                   let barChartDataSet = self.bottomCombinedChartView.barData?.getDataSetByIndex(0) as? ChartDataSet {
                    candlestickChartDataSet.replaceEntries(newCandlestickChartDataEntry)
                    barChartDataSet.replaceEntries(newBarChartDataEntry)
                    var colors = barChartDataSet.colors
                    if !colors.isEmpty {
                        colors.removeLast()
                        colors.append(realtimeTicker.updown.color)
                        barChartDataSet.colors = colors
                    }
                }
                
                self.renderLimitLineAndLimitLineLabel(
                    closePrice: realtimeTicker.safeClosePrice,
                    volume: realtimeTicker.safeVolume,
                    updownColor: realtimeTicker.updown.color
                )
                self.topCombinedChartView.notifyDataSetChanged()
                self.bottomCombinedChartView.notifyDataSetChanged()
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

         self.bottomCombinedChartView.rightAxis.removeAllLimitLines()
         self.bottomCombinedChartView.rightAxis.addLimitLine(volumeLine)
     }
}

extension SingleChartView {

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
