//
//  SceneDelegate.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/02/22.
//

import UIKit
import Moya

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let httpProvider = MoyaProvider<HTTPService>()
        let httpManager = HTTPManager(provider: httpProvider)
        let webSocketManager = WebSocketManager()
        
        let coinListViewModel = CoinListViewModel(httpManager: httpManager, webSocketManager: webSocketManager)
        let coinListViewController = CoinListViewController(viewModel: coinListViewModel)
        let firstTabBarItem = UITabBarItem(title: "거래소", image: UIImage(systemName: "magnifyingglass.circle"), selectedImage: UIImage(systemName: "magnifyingglass.circle.fill"))
        coinListViewController.tabBarItem = firstTabBarItem
        
        let holdingsViewModel = HoldingsViewModel(httpManager: httpManager, webSocketManager: webSocketManager)
        let holdingsViewController = HoldingsViewController(viewModel: holdingsViewModel)
        let secondTabBarItem = UITabBarItem(title: "입출금", image: UIImage(systemName: "magnifyingglass.circle"), selectedImage: UIImage(systemName: "magnifyingglass.circle.fill"))
        holdingsViewController.tabBarItem = secondTabBarItem
        
        let coinListNavigationController = UINavigationController(rootViewController: coinListViewController)
        coinListNavigationController.navigationBar.transparentNavigationBar()
        let holdingsNavigationController = UINavigationController(rootViewController: holdingsViewController)
        holdingsNavigationController.navigationBar.transparentNavigationBar()
        
        let tabBarController = MainTabBarController()
        tabBarController.setViewControllers([coinListNavigationController, holdingsNavigationController], animated: false)
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.backgroundColor = .white
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}       
