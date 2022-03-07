//
//  ChangeRateSettingViewController.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/03.
//

import UIKit

import PanModal
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import Then

class ChangeRateSettingViewController: UIViewController, ViewModelBindable {
    
    private let dismissButton = UIButton().then {
        let image = UIImage(
            systemName: "xmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        $0.setImage(image, for: .normal)
        $0.tintColor = .darkGray
    }
    
    private let periodHeaderView = ChangeRateSettingHeaderView(frame: .zero)
    
    private let periodTableView = UITableView().then {
        $0.register(PeriodCell.self,
                    forCellReuseIdentifier: PeriodCell.identifier)
        $0.isScrollEnabled = false
        $0.separatorStyle = .none
    }
    
    var viewModel: CoinListViewModel
    var disposeBag: DisposeBag = DisposeBag()
    
    required init(viewModel: CoinListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeConstraints()
        self.configureUI()
        self.bind()
    }
    
    func bind() {
        
        self.viewModel.output.changeRatePeriodList
            .map { [SectionModel.init(model: 0, items: $0)] }
            .bind(to: self.periodTableView.rx.items(dataSource: self.createDataSource()))
            .disposed(by: self.disposeBag)
        
        self.periodTableView.rx.modelSelected(ChangeRatePeriod.self)
            .withUnretained(self)
            .bind(onNext: { owner, period in
                self.viewModel.input.selectedChangeRatePeriod.accept(period)
                owner.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        self.dismissButton.rx.tap
            .withUnretained(self)
            .bind(onNext: { owner, _ in
                owner.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        self.periodTableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
    }
    
    typealias PeriodDataSource = RxTableViewSectionedReloadDataSource<SectionModel<Int, ChangeRatePeriod>>
    private func createDataSource() -> PeriodDataSource {
        return PeriodDataSource { _, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PeriodCell.identifier,
                for: indexPath) as? PeriodCell else {
                    return UITableViewCell()
                }
            let checkImage = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 15))
            let currentPeriodImage = self.viewModel.output.currentChangeRatePeriod.value == item ? checkImage : nil
            cell.checkImage.image = currentPeriodImage
            cell.rendering(item)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    private func makeConstraints() {
        self.view.addSubview(self.periodTableView)
        self.view.addSubview(self.dismissButton)
        self.periodTableView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        self.dismissButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().inset(30)
        }
    }
    
    private func configureUI() {
        self.view.backgroundColor = .systemBackground
    }

}

extension ChangeRateSettingViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(Size.longFormHeight)
    }
}

extension ChangeRateSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.periodHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Size.tableViewHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellCount: CGFloat = 5
        return (Size.longFormHeight - Size.tableViewHeaderHeight - Size.panModalTopMargin - (Size.tableViewCellMargin*2)) / cellCount
    }
}

extension ChangeRateSettingViewController {
    enum Size {
        fileprivate static let longFormHeight: CGFloat = 350
        fileprivate static let tableViewHeaderHeight: CGFloat = 100
        fileprivate static let panModalTopMargin: CGFloat = 10
        fileprivate static let tableViewCellMargin: CGFloat = 10
    }
}
