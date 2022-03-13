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
        static let backgroundRed = UIColor.rgb(254, 247, 247)
        static let backgroundBlue = UIColor.rgb(238, 242, 249)
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
    
    enum Parameters {
        // swiftlint:disable all
        static let coinList = ["CHZ", "ALGO", "ICX", "BNT", "RSR", "COLA", "SRM", "KSM", "SSX", "ONT", "UOS", "ETC", "ORBS", "C98", "BIOT", "PUNDIX", "BTT", "LOOM", "MANA", "ALICE", "CRO", "STRAX", "1INCH", "XVS", "CTK", "DOT", "MAP", "XPR", "CELR", "CAKE", "ORC", "COMP", "BTC", "OBSR", "WOO", "WEMIX", "MXC", "ONG", "AQT", "CTC", "XEM", "KLAY", "SOL", "VRA", "WOZX", "ADP", "TFUEL", "ARPA", "BCH", "NU", "ETH", "TRX", "LRC", "SUSHI", "BASIC", "CTSI", "BFC", "GLM", "SPRT", "LINA", "FCT2", "ATOM", "MBL", "DAO", "MLK", "AMO", "WIKEN", "QKC", "BNB", "MKR", "EGLD", "QTCON", "GHX", "ZRX", "ELF", "CWD", "SOC", "BAT", "BURGER", "AAVE", "THETA", "AWO", "BTG", "CON", "MATIC", "DAD", "GRT", "HIBS", "CENNZ", "CYCLUB", "CHR", "XYM", "QTUM", "APM", "COTI", "POLA", "LINK", "GALA", "ANV", "ENJ", "GXC", "DAI", "ZIL", "JST", "CKB", "ANW", "WOM", "DOGE", "OXT", "MM", "NMR", "EL", "LUNA", "DVI", "BORA", "FRONT", "PCI", "VET", "BLY", "COS", "BSV", "MIR", "TRV", "WAVES", "XTZ", "BAKE", "BCD", "XNO", "STEEM", "SNT", "SXP", "MVC", "UMA", "BEL", "EOS", "AERGO", "IOST", "MTL", "WAXP", "MED", "BOA", "REN", "LTC", "FIT", "KNC", "ARW", "SNX", "GOM2", "TEMCO", "VALOR", "XEC", "SOFI", "ADA", "MIX", "GO", "RLC", "MEV", "XRP", "HIVE", "REP", "VSYS", "OCEAN", "APIX", "CTXC", "OMG", "VELO", "FX", "SAND", "BAL", "EGG", "TDROP", "EVZ", "AXS", "BOBA", "YFI", "WICC", "NFT", "TMTG", "ANKR", "ASM", "AION", "RINGX", "IPX", "XLM", "WTC", "RLY", "SUN", "META", "LPT", "UNI", "POWR", "ATOLO"].map { "\($0)_KRW"}
        // swiftline:enable all
    }
}
