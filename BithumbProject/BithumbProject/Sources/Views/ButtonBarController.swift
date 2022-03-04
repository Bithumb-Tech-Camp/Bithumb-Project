//
//  ButtonBarController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/04.
//

import UIKit

import RxCocoa
import RxSwift

final class ButtonBarController: UIViewController, ViewModelBindable {
    
    // MARK: - Public Properties
    public var barBackgroundColor: UIColor = .systemBackground {
        didSet {
            self.view.backgroundColor = self.barBackgroundColor
        }
    }
    
    public var barColor: UIColor = .black {
        didSet {
            self.buttonBarCollectionView.selectedBar.backgroundColor = self.barColor
        }
    }
    
    public var barHeight: CGFloat = 4 {
        didSet {
            self.buttonBarCollectionView.selectedBarHeight = self.barHeight
        }
    }
    
    // MARK: - Private View Properties
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
    }
    
    private lazy var buttonBarCollectionView = ButtonBarCollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
    ).then {
        $0.selectedBarHeight = 3
        $0.register(ButtonBarCell.self, forCellWithReuseIdentifier: ButtonBarCell.idetifier)
    }
    
    private let changeRateSettingButton = UIButton().then {
        $0.setTitle("1시간", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .light)
    }
    
    private let changeRateSettingImage = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 14))
        $0.tintColor = .gray
    }
    
    var viewModel: CoinListViewModel!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.makeConstraints()
    }
    
    // MARK: - bindViewModel
    func bindViewModel() {
        
        // output
        self.viewModel.output.currentChangeRatePeriod
            .withUnretained(self)
            .bind(onNext: { owner, currentPeriod in
                owner.changeRateSettingButton.setTitle(currentPeriod.rawValue, for: .normal)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.requestList
            .bind(to: self.buttonBarCollectionView.rx.items(
                cellIdentifier: ButtonBarCell.idetifier,
                cellType: ButtonBarCell.self)) { _, item, cell in
                    cell.contentLabel.text = item
                }
                .disposed(by: self.disposeBag)
        
        // input
        self.changeRateSettingButton.rx.tap
            .bind(onNext: {
                var changeRateViewController = ChangeRateSettingViewController()
                changeRateViewController.bind(viewModel: self.viewModel)
                self.presentPanModal(changeRateViewController)
            })
            .disposed(by: disposeBag)
        
        self.buttonBarCollectionView.rx.itemSelected
            .bind(onNext: { indexPath in
                self.buttonBarCollectionView.moveTo(index: indexPath.row, animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - View Methods
    
    private func makeConstraints() {
        
        let changeRateStackView = UIStackView(arrangedSubviews: [
            self.changeRateSettingButton,
            self.changeRateSettingImage]
        ).then {
            $0.distribution = .fill
            $0.spacing = 2
            $0.alignment = .center
            $0.axis = .horizontal
        }
        
        self.view.addSubview(changeRateStackView)
        self.view.addSubview(self.buttonBarCollectionView)
        self.buttonBarCollectionView.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.width.equalTo(220)
            make.top.equalToSuperview()
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(20)
        }
        
        changeRateStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(self.buttonBarCollectionView.snp.bottom)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).inset(20)
        }
    }
    
    private func configureUI() {
        self.view.backgroundColor = .systemBackground
    }
    
}
