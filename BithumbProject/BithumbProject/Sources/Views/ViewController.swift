//
//  ViewController.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/02/22.
//

import UIKit

class MyViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    init() {
        self.input = Input()
        self.output = Output()
    }
}

final class ViewController: UIViewController, ViewModelBindable {
    
    var viewModel: MyViewModel!
    
    func bindViewModel() {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
