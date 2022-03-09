//
//  TickerString.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/08.
//

import Foundation

enum TickerString: Codable {

    case ticker(Ticker)
    case string(String)

    init(from decoder: Decoder) throws {

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }

        if let ticker = try? decoder.singleValueContainer().decode(Ticker.self) {
            self = .ticker(ticker)
            return
        }

        throw TickerStringError.notFound
    }

    enum TickerStringError: Error {
        case notFound
    }
}
