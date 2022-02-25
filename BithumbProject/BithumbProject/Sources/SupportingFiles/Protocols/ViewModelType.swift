//
//  ViewModelType.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/02/23.
//

import UIKit

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

protocol ViewModelBindable {
    associatedtype ViewModelType
    var viewModel: ViewModelType! { get set }
    func bindViewModel()
}

extension ViewModelBindable where Self: UIViewController {
    mutating func bind(viewModel: ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}
