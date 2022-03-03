//
//  SceneDelegate.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/02/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let tempRootViewModel = CoinListViewModel()
        var tempRootView = CoinListViewController()
        tempRootView.bind(viewModel: tempRootViewModel)
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.backgroundColor = .white
        window?.rootViewController = UINavigationController(rootViewController: tempRootView)
        window?.makeKeyAndVisible()
    }
}
