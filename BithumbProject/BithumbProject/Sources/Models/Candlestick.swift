//
//  Candlestick.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/23.
//

import Foundation

struct Candlestick {
    var standardTime: Int?      //기준시간
    var openPrice: String?      //시가
    var closePrice: String?     //종가
    var lowPrice: String?       //저가
    var highPrice: String?      //고가
    var transactionVolume: String?  //거래량
}
