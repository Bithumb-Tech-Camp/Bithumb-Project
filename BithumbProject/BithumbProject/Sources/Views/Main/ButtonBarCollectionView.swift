//
//  BarPagerView.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/04.
//

import UIKit

import SnapKit
import Then

final class ButtonBarCollectionView: UICollectionView {

    // collectionView 위에 바를 놓고 이동시키며 구현
    lazy var selectedBar = UIView(
        frame: CGRect(
            x: 0,
            y: self.frame.size.height - CGFloat(self.selectedBarHeight), // 바닥에 붙게
            width: 0,
            height: CGFloat(self.selectedBarHeight))
    ).then {
        // Z축 최상위 뷰
        $0.layer.zPosition = 9999
        $0.backgroundColor = .black
    }

    // 바 높이
    public var selectedBarHeight: CGFloat = 4 {
        didSet {
            self.updateSelectedBarYPosition()
        }
    }
    
    // enum으로 Alignment 관리, 기본 값 사용 (private)
    private var selectedBarVerticalAlignment: SelectedBarVerticalAlignment = .bottom
    private var selectedBarHorizontalAlignment: SelectedBarHorizontalAlignment = .center
    
    // 현재 선택한 셀의 Index
    var selectedIndex = 0

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.addSubview(self.selectedBar)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(self.selectedBar)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Y 포지션 설정값 업데이트하는 함수
        self.updateSelectedBarYPosition()
    }

    // index를 받으면 해당 위치로 바가 이동하도록 하는 함수
    func moveTo(index: Int, animated: Bool) {
        self.selectedIndex = index
        self.updateSelectedBarPosition(animated)
    }

    // 바의 위치를 변경하는 함수
    func updateSelectedBarPosition(_ animated: Bool) {
        var selectedBarFrame = self.selectedBar.frame

        // 선택된 indexPath
        let selectedCellIndexPath = IndexPath(item: self.selectedIndex, section: 0)
        // 해당 indexPath에 있는 Item의  layout information을 검색해서 가져옴. 즉, frame, bounds와 같은 속성들을 가져올 수 있따.
        let attributes = layoutAttributesForItem(at: selectedCellIndexPath)
        // 선택한 Item의 프레임을 사용함
        let selectedCellFrame = attributes!.frame

        self.updateContentOffset(animated: animated, toFrame: selectedCellFrame, toIndex: (selectedCellIndexPath as NSIndexPath).row)
        
        // 셀의 프레임을 우리가 보여줄 언더바 프레임에 넣어줘서 크기와 위치를 조정
        selectedBarFrame.size.width = selectedCellFrame.size.width
        selectedBarFrame.origin.x = selectedCellFrame.origin.x

        // 애니메이션 여부에 따라 프레임을 조정해 애니메이션 이동이 되도록 구현
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.selectedBar.frame = selectedBarFrame
            })
        } else {
            selectedBar.frame = selectedBarFrame
        }
    }

    // MARK: - Helpers

    private func updateContentOffset(animated: Bool, toFrame: CGRect, toIndex: Int) {
        // 선택한 셀의 x축 위치가 컬렉션뷰 밖으로 나가는 예외처리
        guard toFrame.origin.x < self.contentOffset.x || toFrame.origin.x >= (self.contentOffset.x + self.frame.size.width - self.contentInset.left) else {
            return
        }
        let targetContentOffset = self.contentSize.width > self.frame.size.width ? contentOffsetForCell(withFrame: toFrame, andIndex: toIndex) : 0
        setContentOffset(CGPoint(x: targetContentOffset, y: 0), animated: animated)
    }

    private func contentOffsetForCell(withFrame cellFrame: CGRect, andIndex index: Int) -> CGFloat {
        var contentOffset = cellFrame.origin.x - (frame.size.width - cellFrame.size.width) * 0.5
        contentOffset = max(0, contentOffset)
        contentOffset = min(contentSize.width - frame.size.width, contentOffset)
        return contentOffset
    }

    private func updateSelectedBarYPosition() {
        var selectedBarFrame = self.selectedBar.frame

        switch self.selectedBarVerticalAlignment {
        case .top:
            selectedBarFrame.origin.y = 0
        case .middle:
            selectedBarFrame.origin.y = (frame.size.height - selectedBarHeight) / 2
        case .bottom:
            selectedBarFrame.origin.y = frame.size.height - selectedBarHeight
        }

        selectedBarFrame.size.height = self.selectedBarHeight
        self.selectedBar.frame = selectedBarFrame
    }
}

extension ButtonBarCollectionView {
    enum SelectedBarVerticalAlignment {
        case top
        case bottom
        case middle
    }
    
    enum SelectedBarHorizontalAlignment {
        case center
    }
}
