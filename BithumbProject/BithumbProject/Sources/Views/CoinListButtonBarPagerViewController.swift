//
//  CoinListButtonBarPagerViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/03.
//

import Foundation

import PanModal
import RxCocoa
import RxSwift
import Then
import XLPagerTabStrip

final class CoinListButtonBarPagerViewController: ButtonBarPagerTabStripViewController, ViewModelBindable {

    // MARK: - View Properties
    private let scrollView: UIScrollView = UIScrollView()
    
    private let buttonBarPagerView: ButtonBarView = ButtonBarView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
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
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        self.setupViews()
        self.configureStrip()
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [KRWViewController(), PopularityViewController(), FavoriteCoinViewController()]
    }
    
    func bindViewModel() {
        self.changeRateSettingButton.rx.tap
            .bind(onNext: {
                var changeRateViewController = ChangeRateSettingViewController()
                changeRateViewController.bind(viewModel: self.viewModel)
                self.presentPanModal(changeRateViewController)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
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
        self.view.addSubview(self.buttonBarPagerView)
        self.view.addSubview(self.scrollView)
        
        self.buttonBarPagerView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(220)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
        }
        
        changeRateStackView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.buttonBarPagerView.snp.bottom)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).inset(20)
        }
    
        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(buttonBarPagerView.snp.bottom)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func configureStrip() {
        self.settings.style.buttonBarBackgroundColor = .white
        self.settings.style.buttonBarItemBackgroundColor = .white
        self.settings.style.selectedBarBackgroundColor = .black
        self.settings.style.buttonBarItemFont = Font.defaultFont
        self.settings.style.selectedBarHeight = 3
        self.settings.style.buttonBarMinimumLineSpacing = 0
        self.settings.style.buttonBarItemTitleColor = Font.defaultTextColor
        self.settings.style.buttonBarItemsShouldFillAvailableWidth = true
        self.settings.style.buttonBarLeftContentInset = 20
        self.settings.style.buttonBarRightContentInset = 20
        
        // swiftlint:disable all
        self.changeCurrentIndexProgressive = {(
            oldCell: ButtonBarViewCell?,
            newCell: ButtonBarViewCell?,
            progressPercentage: CGFloat,
            changeCurrentIndex: Bool,
            animated: Bool) -> Void in
            guard changeCurrentIndex == true else {
                return
            }
            oldCell?.label.font = Font.defaultFont
            oldCell?.label.textColor = Font.defaultTextColor
            newCell?.label.font = Font.selectedFont
            newCell?.label.textColor = Font.selectedTextColor
        }
        // swiftlint:enable all
        
        self.buttonBarView = self.buttonBarPagerView
        self.containerView = self.scrollView
    }
}

extension CoinListButtonBarPagerViewController {
    enum Font {
        fileprivate static let defaultFont: UIFont = .systemFont(ofSize: 17, weight: .semibold)
        fileprivate static let defaultTextColor: UIColor = .systemGray
        fileprivate static let selectedFont: UIFont = .systemFont(ofSize: 17, weight: .semibold)
        fileprivate static let selectedTextColor: UIColor = .black
    }
}
