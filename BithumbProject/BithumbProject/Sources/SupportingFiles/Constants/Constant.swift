//
//  Constant.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/22.
//

import UIKit

typealias Const = Constant
typealias Color = Const.Color
typealias Text = Const.UI.Text
typealias Image = Const.UI.Image
typealias Screen = Const.UI.Screen

enum Constant {
    
    enum UI {

        enum Screen {
            static let width = UIScreen.main.bounds.width
            static let height = UIScreen.main.bounds.height
        }
        
        enum Text {
            enum TabBar {
                static let home = "Home"
                static let bid = "입찰"
            }
        }
        
        enum Image {
            enum Name {
                static let mainBackground = "main_bg"
            }
        }
    }
    
    enum Device {
        static let systemName = UIDevice.current.systemName.uppercased()
        static let systemVersion = UIDevice.current.systemVersion
    }
    
    enum Color {
        static let clear = UIColor.clear
        static let backgroundRed = UIColor.rgb(254, 240, 238)
        static let backgroundBlue = UIColor.rgb(237, 246, 255)
        static let barBlue = UIColor.rgb(189, 212, 252)
        static let barRed = UIColor.rgb(251, 195, 201)
    }
    
    enum URL {
        static let webSocketBaseURL = "wss://pubwss.bithumb.com/pub/ws"
        static let httpBaseURL = "https://api.bithumb.com/public"
        static let cafeURL = "https://cafe.bithumb.com/view/board-contents/1642708"
    }

    enum Path {
        static let tickerPath = "/ticker"
        static let assetsStatusPath = "/assetsstatus"
        static let candleStickPath = "/candlestick"
        static let orderBookPath = "/orderbook"
        static let transationHistoryPath = "/transaction_history"
    }
}
