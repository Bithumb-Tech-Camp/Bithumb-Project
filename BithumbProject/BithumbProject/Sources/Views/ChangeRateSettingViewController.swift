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
        $0.register(PeriodTableViewCell.self,
                    forCellReuseIdentifier: PeriodTableViewCell.identifier)
    }
    
    var viewModel: CoinListViewModel!
    var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeConstraints()
        self.configureUI()
    }
    
    func bindViewModel() {
        
        Observable.from([])
            .bind(to: self.periodTableView.rx.items(dataSource: createDataSource()))
            .disposed(by: self.disposeBag)
        
        //        self.periodTableView.rx.modelSelected(ChangeRate.self)
        
        self.dismissButton.rx.tap
            .withUnretained(self)
            .bind(onNext: { owner, _ in
                owner.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        self.periodTableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
    }
    
    typealias PeriodDataSource = RxTableViewSectionedReloadDataSource<SectionModel<Int, ChangeRate>>
    private func createDataSource() -> PeriodDataSource {
        return PeriodDataSource { datasource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PeriodTableViewCell.identifier,
                for: indexPath) as? PeriodTableViewCell else {
                    return UITableViewCell()
                }
            cell.rendering(item)
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
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(400)
    }
}

extension ChangeRateSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.periodHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
}

struct ChangeRate {
    enum Period {
        case MID
        case Day
        case HalfDay
        case Hour
        case HalfHour
    }
    
    let time: Period
    let isSelected: Bool = false
}
