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
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
