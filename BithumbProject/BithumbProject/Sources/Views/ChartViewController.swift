//
//  ChartViewController.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/02.
//

import UIKit
import XLPagerTabStrip

class ChartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension ChartViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: "차트")
    }
}
