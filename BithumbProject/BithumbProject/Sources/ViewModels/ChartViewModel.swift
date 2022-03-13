//
//  ChartViewModel.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/04.
//

import Foundation

import RxSwift
import RxRelay
import Charts

final class ChartViewModel: ViewModelType {
    
    struct Input {
        let fetchCandlestick: PublishSubject<Void> = PublishSubject<Void>()
        let fetchRemoteCandlestick: PublishSubject<Void> = PublishSubject<Void>()
        let fetchRealtimeTicker: PublishSubject<Void> = PublishSubject<Void>()
        let saveRemoteCandlestick: PublishSubject<[Candlestick]> = PublishSubject<[Candlestick]>()
        var changeOption: BehaviorSubject<ChartOption> = BehaviorSubject<ChartOption>(
            value: ChartOption(orderCurrency: "BTC_KRW", interval: .day, layout: .single)
        )
    }
    
    struct Output {
        let candlesticks: BehaviorRelay<[Candlestick]> = BehaviorRelay<[Candlestick]>(value: [])
        let realtimeTicker: BehaviorRelay<RealtimeTicker> = BehaviorRelay<RealtimeTicker>(value: RealtimeTicker.empty)
        var option: BehaviorRelay<ChartOption> = BehaviorRelay<ChartOption>(
            value: ChartOption(orderCurrency: "BTC_KRW", interval: .day, layout: .single)
        )
        let isActivated: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
        
        let candlestickChartDataEntry: PublishRelay<[CandleChartDataEntry]> = PublishRelay<[CandleChartDataEntry]>()
        let candlestickMA5LineChartEntry: PublishRelay<[ChartDataEntry]> = PublishRelay<[ChartDataEntry]>()
        let candlestickMA10LineChartEntry: PublishRelay<[ChartDataEntry]> = PublishRelay<[ChartDataEntry]>()
        let candlestickMA20LineChartEntry: PublishRelay<[ChartDataEntry]> = PublishRelay<[ChartDataEntry]>()
        let candlestickMA60LineChartEntry: PublishRelay<[ChartDataEntry]> = PublishRelay<[ChartDataEntry]>()
        let candlestickMA120LineChartEntry: PublishRelay<[ChartDataEntry]> = PublishRelay<[ChartDataEntry]>()
        let candlestickXAxisLabel: PublishRelay<[String]> = PublishRelay<[String]>()
        
        let barChartDataEntry: PublishRelay<[BarChartDataEntry]> = PublishRelay<[BarChartDataEntry]>()
        let barMA5LineChartEntry: PublishRelay<[ChartDataEntry]> = PublishRelay<[ChartDataEntry]>()
        let barMA10LineChartEntry: PublishRelay<[ChartDataEntry]> = PublishRelay<[ChartDataEntry]>()
        let barMA20LineChartEntry: PublishRelay<[ChartDataEntry]> = PublishRelay<[ChartDataEntry]>()
        let barMA60LineChartEntry: PublishRelay<[ChartDataEntry]> = PublishRelay<[ChartDataEntry]>()
        let barMA120LineChartEntry: PublishRelay<[ChartDataEntry]> = PublishRelay<[ChartDataEntry]>()
        
        let candlestickChartDataSet: PublishRelay<CandleChartDataSet> = PublishRelay<CandleChartDataSet>()
        let candlestickMA5LineChartDataSet: PublishRelay<LineChartDataSet> = PublishRelay<LineChartDataSet>()
        let candlestickMA10LineChartDataSet: PublishRelay<LineChartDataSet> = PublishRelay<LineChartDataSet>()
        let candlestickMA20LineChartDataSet: PublishRelay<LineChartDataSet> = PublishRelay<LineChartDataSet>()
        let candlestickMA60LineChartDataSet: PublishRelay<LineChartDataSet> = PublishRelay<LineChartDataSet>()
        let candlestickMA120LineChartDataSet: PublishRelay<LineChartDataSet> = PublishRelay<LineChartDataSet>()
        
        let barChartDataSet: PublishRelay<BarChartDataSet> = PublishRelay<BarChartDataSet>()
        let barMA5LineChartDataSet: PublishRelay<LineChartDataSet> = PublishRelay<LineChartDataSet>()
        let barMA10LineChartDataSet: PublishRelay<LineChartDataSet> = PublishRelay<LineChartDataSet>()
        let barMA20LineChartDataSet: PublishRelay<LineChartDataSet> = PublishRelay<LineChartDataSet>()
        let barMA60LineChartDataSet: PublishRelay<LineChartDataSet> = PublishRelay<LineChartDataSet>()
        let barMA120LineChartDataSet: PublishRelay<LineChartDataSet> = PublishRelay<LineChartDataSet>()
        
        let error: PublishRelay<NSError> = PublishRelay<NSError>()
    }
    
    var input: Input
    var output: Output
    var disposeBag: DisposeBag = DisposeBag()
    
    init(coin: Coin, httpManager: HTTPManager, webSocketManager: WebSocketManager, realmManager: RealmManager) {

        self.input = Input()
        self.output = Output()
        
        input.changeOption = BehaviorSubject<ChartOption>(
            value: ChartOption(orderCurrency: coin.orderCurrency, interval: .day, layout: .single)
        )
        output.option = BehaviorRelay<ChartOption>(
            value: ChartOption(orderCurrency: coin.orderCurrency, interval: .day, layout: .single)
        )
        
        setupInput(httpManager: httpManager, webSocketManager: webSocketManager, realmManager: realmManager)
        setupOutput()
    }
    
    private func setupInput(httpManager: HTTPManager, webSocketManager: WebSocketManager, realmManager: RealmManager) {
        
        Observable.combineLatest(input.fetchCandlestick, input.changeOption)
            .distinctUntilChanged({ $0.1 == $1.1 })
             .flatMap {[weak self] _, option -> Observable<[Candlestick]> in
                 self?.output.isActivated.accept(true)
                 return realmManager.requestCandlesticks(option: option)
             }
            .flatMap {[weak self] candlesticks -> Observable<[Candlestick]> in
                if candlesticks.isEmpty {
                    self?.input.fetchRemoteCandlestick.onNext(())
                }
                return Observable.just(candlesticks)
            }
            .subscribe(onNext: {[weak self] candlesticks in
                self?.output.isActivated.accept(false)
                self?.output.candlesticks.accept(candlesticks)
            }, onError: {[weak self] error in
                self?.output.isActivated.accept(false)
                self?.output.error.accept(error as NSError)
            })
            .disposed(by: disposeBag)
        
        input.fetchRemoteCandlestick
            .withLatestFrom(input.changeOption)
            .flatMap { option -> Observable<[[IntString]]> in
                httpManager.request(
                    httpServiceType: .candleStick(option.orderCurrency, option.interval.toAPI),
                    model: [[IntString]].self
                )
            }
            .map { $0.map { Candlestick(array: $0) } }
            .subscribe(onNext: {[weak self] candlesticks in
                self?.output.candlesticks.accept(candlesticks)
                self?.input.saveRemoteCandlestick.onNext(candlesticks)
            }, onError: {[weak self] error in
                self?.output.isActivated.accept(false)
                self?.output.error.accept(error as NSError)
            })
            .disposed(by: disposeBag)
        
        input.saveRemoteCandlestick
            .subscribe(on: SerialDispatchQueueScheduler.init(qos: .background))
            .subscribe(onNext: {[weak self] candlesticks in
                guard let self = self else { return }
                self.output.isActivated.accept(false)
                realmManager.saveCandlesticks(option: self.output.option.value, candlesticks: candlesticks)
            }, onError: {[weak self] error in
                self?.output.isActivated.accept(false)
                self?.output.error.accept(error as NSError)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.fetchRealtimeTicker, input.changeOption)
            .flatMap { _, option -> Observable<RealtimeTicker> in
                let parameter: [String: Any] = [
                    "type": BithumbWebSocketRequestType.ticker.rawValue,
                    "symbols": [option.orderCurrency],
                    "tickTypes": [RealtimeTickType(tickType: option.interval.toAPI)].compactMap { $0?.rawValue }
                ]
                return webSocketManager.requestRealtime(parameter: parameter, type: RealtimeTicker.self)
            }
            .filter { !$0.isEmpty }
            .subscribe(onNext: {[weak self] realtimeTicker in
                guard let self = self else { return }
                self.output.realtimeTicker.accept(realtimeTicker)
            }, onError: {[weak self] error in
                guard let self = self else { return }
                self.output.error.accept(error as NSError)
            })
            .disposed(by: disposeBag)
        
        input.changeOption
            .subscribe(onNext: {[weak self] option in
                self?.output.option.accept(option)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupOutput() {
        output.candlesticks
            .filter { !$0.isEmpty }
            .subscribe(onNext: {[weak self] candlesticks in
                guard let self = self else { return }
                self.output.candlestickChartDataEntry.accept(
                    candlesticks.enumerated().map { index, candlestick in
                        CandleChartDataEntry(
                            x: Double(index),
                            shadowH: candlestick.safeHighPrice,
                            shadowL: candlestick.safeLowPrice,
                            open: candlestick.safeOpenPrice,
                            close: candlestick.safeClosePrice
                        )
                    }
                )
                self.output.barChartDataEntry.accept(
                    candlesticks.enumerated().map { index, candlestick in
                        BarChartDataEntry(x: Double(index), y: candlestick.safeTransactionVolume)
                    }
                )
                self.output.candlestickMA5LineChartEntry.accept(
                    self.setupCandlestickMALineChartDataEntry(num: 5, candlesticks: candlesticks)
                )
                self.output.candlestickMA10LineChartEntry.accept(
                    self.setupCandlestickMALineChartDataEntry(num: 10, candlesticks: candlesticks)
                )
                self.output.candlestickMA20LineChartEntry.accept(
                    self.setupCandlestickMALineChartDataEntry(num: 20, candlesticks: candlesticks)
                )
                self.output.candlestickMA60LineChartEntry.accept(
                    self.setupCandlestickMALineChartDataEntry(num: 60, candlesticks: candlesticks)
                )
                self.output.candlestickMA120LineChartEntry.accept(
                    self.setupCandlestickMALineChartDataEntry(num: 120, candlesticks: candlesticks)
                )
                self.output.barMA5LineChartEntry.accept(
                    self.setupBarMALineChartDataEntry(num: 5, candlesticks: candlesticks)
                )
                self.output.barMA10LineChartEntry.accept(
                    self.setupBarMALineChartDataEntry(num: 10, candlesticks: candlesticks)
                )
                self.output.barMA20LineChartEntry.accept(
                    self.setupBarMALineChartDataEntry(num: 20, candlesticks: candlesticks)
                )
                self.output.barMA60LineChartEntry.accept(
                    self.setupBarMALineChartDataEntry(num: 60, candlesticks: candlesticks)
                )
                self.output.barMA120LineChartEntry.accept(
                    self.setupBarMALineChartDataEntry(num: 120, candlesticks: candlesticks)
                )
            })
            .disposed(by: disposeBag)
        
        output.candlesticks
            .filter { !$0.isEmpty }
            .withLatestFrom(output.option) { ($0, $1) }
            .subscribe(onNext: {[weak self] candlesticks, option in
                guard let self = self else { return }
                let dataXAxisLabel = self.setupXAxisLabel(candlesticks: candlesticks, option: option)
                self.output.candlestickXAxisLabel.accept(dataXAxisLabel)
            })
            .disposed(by: disposeBag)
        
        output.candlestickChartDataEntry
            .filter { !$0.isEmpty }
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.candlestickChartDataSet.accept(
                    self.setupCandlestickChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
        
        output.candlesticks
            .withLatestFrom(output.barChartDataEntry) { ($0, $1) }
            .filter { !$0.0.isEmpty && !$0.1.isEmpty }
            .subscribe(onNext: {[weak self] candlesticks, entries in
                guard let self = self else { return }
                let colors = candlesticks.map { $0.updown.color }
                self.output.barChartDataSet.accept(
                    self.setupBarChartDataSet(entries: entries, colors: colors)
                )
            })
            .disposed(by: disposeBag)
        
        output.candlestickMA5LineChartEntry
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.candlestickMA5LineChartDataSet.accept(
                    self.setupMA5LineChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
        
        output.candlestickMA10LineChartEntry
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.candlestickMA10LineChartDataSet.accept(
                    self.setupMA10LineChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
        
        output.candlestickMA20LineChartEntry
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.candlestickMA20LineChartDataSet.accept(
                    self.setupMA20LineChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
        
        output.candlestickMA60LineChartEntry
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.candlestickMA60LineChartDataSet.accept(
                    self.setupMA60LineChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
        
        output.candlestickMA120LineChartEntry
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.candlestickMA120LineChartDataSet.accept(
                    self.setupMA120LineChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
        
        output.barMA5LineChartEntry
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.barMA5LineChartDataSet.accept(
                    self.setupMA5LineChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
        
        output.barMA10LineChartEntry
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.barMA10LineChartDataSet.accept(
                    self.setupMA10LineChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
        
        output.barMA20LineChartEntry
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.barMA20LineChartDataSet.accept(
                    self.setupMA20LineChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
        
        output.barMA60LineChartEntry
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.barMA60LineChartDataSet.accept(
                    self.setupMA60LineChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
        
        output.barMA120LineChartEntry
            .subscribe(onNext: {[weak self] entries in
                guard let self = self else { return }
                self.output.barMA120LineChartDataSet.accept(
                    self.setupMA120LineChartDataSet(entries: entries)
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func setupCandlestickMALineChartDataEntry(
        num: Int,
        candlesticks: [Candlestick]
    ) -> [ChartDataEntry] {
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
    
    private func setupBarMALineChartDataEntry(
        num: Int,
        candlesticks: [Candlestick]
    ) -> [ChartDataEntry] {
        if candlesticks.count <= 0 || candlesticks.count < num {
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
    
    private func setupXAxisLabel(candlesticks: [Candlestick], option: ChartOption) -> [String] {
        return candlesticks.compactMap { (candlestick: Candlestick) -> String? in
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
    }
    
    private func setupCandlestickChartDataSet(entries: [CandleChartDataEntry]) -> CandleChartDataSet {
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
    
    private func setupBarChartDataSet(entries: [BarChartDataEntry], colors: [UIColor]) -> BarChartDataSet {
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
}
