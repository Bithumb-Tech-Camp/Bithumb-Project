//
//  HoldingsViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/09.
//

import UIKit

import RxCocoa
import RxSwift

final class HoldingsViewController: UIViewController, ViewModelBindable {
      
    var viewModel: HoldingsViewModel
    var disposeBag: DisposeBag = DisposeBag()
    
    init(viewModel: HoldingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
        
    }
    
    func bind() {
        
    }
    

}
