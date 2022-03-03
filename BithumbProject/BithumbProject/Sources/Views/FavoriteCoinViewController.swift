//
//  FavoriteCoinViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/03.
//

import UIKit

import XLPagerTabStrip

class FavoriteCoinViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGreen
    }
}

extension FavoriteCoinViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: "관심")
    }
}
