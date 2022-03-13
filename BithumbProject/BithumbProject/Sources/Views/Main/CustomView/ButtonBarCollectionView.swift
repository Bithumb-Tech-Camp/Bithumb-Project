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

    lazy var selectedBar = UIView(
        frame: CGRect(
            x: 0,
            y: self.frame.size.height - CGFloat(self.selectedBarHeight), // 바닥에 붙게
            width: 0,
            height: CGFloat(self.selectedBarHeight))
    ).then {
        $0.layer.zPosition = 9999
        $0.backgroundColor = .black
    }

    public var selectedBarHeight: CGFloat = 4 {
        didSet {
            self.updateSelectedBarYPosition()
        }
    }
    
    private var selectedBarVerticalAlignment: SelectedBarVerticalAlignment = .bottom
    private var selectedBarHorizontalAlignment: SelectedBarHorizontalAlignment = .center
    
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
        self.updateSelectedBarYPosition()
    }

    func moveTo(index: Int, animated: Bool) {
        self.selectedIndex = index
        self.updateSelectedBarPosition(animated)
    }

    func updateSelectedBarPosition(_ animated: Bool) {
        var selectedBarFrame = self.selectedBar.frame

        let selectedCellIndexPath = IndexPath(item: self.selectedIndex, section: 0)
        let attributes = layoutAttributesForItem(at: selectedCellIndexPath)
        let selectedCellFrame = attributes!.frame

        self.updateContentOffset(animated: animated, toFrame: selectedCellFrame, toIndex: (selectedCellIndexPath as NSIndexPath).row)
        
        selectedBarFrame.size.width = selectedCellFrame.size.width
        selectedBarFrame.origin.x = selectedCellFrame.origin.x

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
