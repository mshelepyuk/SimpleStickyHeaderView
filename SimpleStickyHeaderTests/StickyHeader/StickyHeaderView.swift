//
//  StickyHeaderView.swift
//  SimpleStickyHeaderTests
//
//  Created by Maxim Shelepyuk.
//  Copyright © 2562 Maxim Shelepyuk. All rights reserved.
//

import UIKit

protocol StickyHeaderViewDelegate: class {
    func stickyHeader(_ stickyHeader: StickyHeaderView, progressDidChanged progress: CGFloat)
}

class StickyHeaderView: UIView {
    private let scrollView: UIScrollView
    private let headerView: UIView
    
    private var headerViewTopConstraint: NSLayoutConstraint?
    
    private var offsetObservation: NSKeyValueObservation?
    private var headerFrameObservation: NSKeyValueObservation?
    
    weak var delegate: StickyHeaderViewDelegate?
    
    var minimumHeaderHeight: CGFloat = 0.0
    
    private(set) var progress: CGFloat = 0.0 {
        didSet {
            guard oldValue != progress else { return }
            delegate?.stickyHeader(self, progressDidChanged: progress)
        }
    }
    
    private var cachedHeight: CGFloat?
    
    deinit {
        unsubscribeFromHeaderBoundsChanges()
        unsubscribeFromScrollViewOffsetChanges()
    }
    
    init(headerView: UIView, scrollView: UIScrollView) {
        self.scrollView = scrollView
        self.headerView = headerView
        
        super.init(frame: .zero)
        
        configure()
        configureLayout()
        updateInsets()
        
        subscribeForScrollViewOffsetChanges()
        subscribeForHeaderBoundsChanges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StickyHeaderView {
    
    private func configure() {
        addSubview(scrollView)
        addSubview(headerView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureLayout() {
        headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: topAnchor)
        headerViewTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate(
            [
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                scrollView.leftAnchor.constraint(equalTo: leftAnchor),
                scrollView.rightAnchor.constraint(equalTo: rightAnchor),
                headerView.leftAnchor.constraint(equalTo: leftAnchor),
                headerView.rightAnchor.constraint(equalTo: rightAnchor)
            ]
        )
    }
    
    private func updateInsets() {
        let headerHeight = headerView.systemLayoutSizeFitting(.zero).height
        cachedHeight = headerHeight
        scrollView.contentInset.top = headerHeight
        scrollView.scrollIndicatorInsets.top = headerHeight
        
        moveScrollViewOffsetY(to: -headerHeight)
    }
    
    private func moveScrollViewOffsetY(to position: CGFloat) {
        scrollView.contentOffset.y = position
    }
}

extension StickyHeaderView {
    
    private func subscribeForHeaderBoundsChanges() {
        headerFrameObservation = headerView.observe(\.bounds, options: [.new, .old], changeHandler: { [weak self] (headerView, value) in
            guard value.oldValue != value.newValue else { return }
            self?.headerBoundsDidChanged()
        })
    }
    
    private func headerBoundsDidChanged() {
        updateInsets()
    }
    
    private func subscribeForScrollViewOffsetChanges() {
        offsetObservation = scrollView.observe(\.contentOffset, options: [.new, .old]) { [weak self] (scrollView, value) in
            guard value.oldValue != value.newValue else { return }
            self?.offsetDidChanged(offset: scrollView.contentOffset)
        }
    }
    
    private func offsetDidChanged(offset: CGPoint) {
        moveHeader(relatively: offset)
    }
    
    private func unsubscribeFromScrollViewOffsetChanges() {
        offsetObservation?.invalidate()
    }
    
    private func unsubscribeFromHeaderBoundsChanges() {
        headerFrameObservation?.invalidate()
    }
}

extension StickyHeaderView {
    
    private func moveHeader(relatively contentOffset: CGPoint) {
        guard let headerViewTopConstraint = headerViewTopConstraint else { return }
        
        let headerHeight = cachedHeight ?? headerView.systemLayoutSizeFitting(.zero).height
        let heightsDifference = headerHeight - minimumHeaderHeight
        let relativeYOffset = contentOffset.y + headerHeight
        let constraintConstant = max(-relativeYOffset, -heightsDifference)
        
        headerViewTopConstraint.constant = relativeYOffset <= 0 ? 0 : constraintConstant
        progress = relativeYOffset <= 0 ? 0 : abs(constraintConstant / heightsDifference)
    }
}
