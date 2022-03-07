//
//  SortedColumn.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/05.
//

import Foundation

final class SortedColumn {
    enum Sorting {
        case ascending
        case descending

        var symbol: String {
            switch self {
            case .ascending:
                return " \u{25B2}"
            case .descending:
                return " \u{25BC}"
            }
        }
    }
   
    var column: Int
    var sorting: Sorting
    var name: String {
        switch self.column {
        case 0:
            return "가산자산명"
        case 1:
            return "현재가"
        case 2:
            return "변동률"
        case 3:
            return "거래금액"
        default:
            return ""
        }
    }
    
    init(column: Int,
         sorting: Sorting = .ascending ) {
        self.column = column
        self.sorting = sorting
    }
    
    func toggling(_ column: Int) {
        if self.column == column {
            let changeSorting = self.sorting == .ascending
            self.sorting = changeSorting ? .descending : .ascending
        }
    }
}

extension SortedColumn: Equatable {
    static func == (lhs: SortedColumn, rhs: SortedColumn) -> Bool {
        return lhs.column == rhs.column && lhs.sorting == rhs.sorting
    }
}
