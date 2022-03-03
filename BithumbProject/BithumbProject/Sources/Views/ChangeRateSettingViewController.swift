//
//  ChangeRateSettingViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/03.
//

import UIKit

import PanModal

class ChangeRateSettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPink
    }

}

extension ChangeRateSettingViewController: PanModalPresentable {

    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(300)
    }

    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(40)
    }
    
}
