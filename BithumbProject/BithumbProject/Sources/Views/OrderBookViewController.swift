//
//  OrderBookViewController.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/26.
//

import Foundation
import UIKit
import RxSwift
import SpreadsheetView
import RxDataSources

class OrderBookViewController: UIViewController {
    var disposeBag = DisposeBag()
    let viewModel = OrderBookViewModel()
//    let baseView = OrderBookView()
    
    let spreadSheetView = SpreadsheetView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        self.spreadSheetView.delegate = self
        self.spreadSheetView.dataSource = self
        
        self.spreadSheetView.register(OrderBookCell.self, forCellWithReuseIdentifier: String(describing: OrderBookCell.self))
        
        view.addSubview(self.spreadSheetView)
        spreadSheetView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets.zero)
        }
        
        self.viewModel.output.dummyData
            
        
    }
}

extension OrderBookViewController: SpreadsheetViewDelegate {
    
}

extension OrderBookViewController: SpreadsheetViewDataSource {
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return Screen.width / 3
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 30
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        3
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        60
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        return [
            CellRange(from: (row: 0, column: 2), to: (row: 29, column: 2)),
            CellRange(from: (row: 30, column: 0), to: (row: 59, column: 0))
        ]
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: OrderBookCell.self), for: indexPath) as? OrderBookCell
        
        if indexPath.column ==  0 && indexPath.row < 30 {
            cell?.label.text = "0.12345"
            cell?.label.textAlignment = .right
            cell?.contentView.backgroundColor = .blue
        }
        
        if indexPath.column ==  1 {
            if indexPath.row < 30 {
                cell?.label.text = "45,678,912"
                cell?.label.textAlignment = .center
                cell?.contentView.backgroundColor = .blue
            } else {
                cell?.label.text = "45,678,912"
                cell?.label.textAlignment = .center
                cell?.contentView.backgroundColor = .red
            }
        }
        
        if indexPath.column ==  2 && indexPath.row >= 30 {
            cell?.label.text = "0.12345"
            cell?.label.textAlignment = .left
            cell?.contentView.backgroundColor = .red
        }
        
        return cell
    }
}
