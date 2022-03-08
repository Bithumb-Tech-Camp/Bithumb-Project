//
//  MainTabBarController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/09.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTabBarBackgroundColor()
        self.setTabBarItemColor()
    }
    
    private func setTabBarBackgroundColor() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().backgroundColor = .systemBackground
    }
    
    private func setTabBarItemColor() {
        self.tabBar.tintColor = .darkGray
        self.tabBar.unselectedItemTintColor = .systemGray
    }

}
