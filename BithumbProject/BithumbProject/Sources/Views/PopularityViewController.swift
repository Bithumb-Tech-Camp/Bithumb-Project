//
//  PopularityViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/03.
//

import UIKit

import XLPagerTabStrip

class PopularityViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .label
    }
}

extension PopularityViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: "인기")
    }
}
