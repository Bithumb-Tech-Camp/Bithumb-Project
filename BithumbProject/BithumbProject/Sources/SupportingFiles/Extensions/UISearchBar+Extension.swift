//
//  UISearchBar+Extension.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/03.
//

import UIKit

extension UISearchBar {
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton: UIBarButtonItem = UIBarButtonItem(title:  NSLocalizedString("닫기", comment: ""), style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpaceItem, doneBarButton]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        self.resignFirstResponder()
    }
}
