//
//  ViewController.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/02/22.
//

import UIKit
import RxSwift
import RxCocoa

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

final class ViewController: UIViewController {
    
    let httpManager = HTTPManager()
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        httpManager.requestCoinList()
            .subscribe(onNext: { coinList in
                print(coinList)
            })
            .disposed(by: self.disposeBag)
    }
}

