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
    }
    
    enum URL {
        static let webSocketBaseURL = "wss://pubwss.bithumb.com/pub/ws"
        static let httpBaseURL = "https://api.bithumb.com/public"
    }

    enum Path {
        static let tickerPath = "/ticker"
        static let assetsStatusPath = "/assetsstatus"
        static let candleStickPath = "/candlestick"
        static let orderBookPath = "/orderbook"
    }
}
