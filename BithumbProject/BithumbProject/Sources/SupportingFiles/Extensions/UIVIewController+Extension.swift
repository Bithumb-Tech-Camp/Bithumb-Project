//
//  UIVIewController+Extension.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/04.
//

import SafariServices
import UIKit

extension UIViewController {
    func alertMessage(message: String) {
        let alertController = UIAlertController(
            title: "알림",
            message: message,
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "확인",
            style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
