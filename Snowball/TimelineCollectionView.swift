//
//  TimelineCollectionView.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class TimelineCollectionView: UICollectionView {

  // MARK: Properties

  var timelineDelegate: TimelineCollectionViewDelegate?

  fileprivate let leftSwipeGestureRecognizer: UISwipeGestureRecognizer = {
    let gestureRecognizer = UISwipeGestureRecognizer()
    gestureRecognizer.direction = .left
    return gestureRecognizer
  }()

  fileprivate let rightSwipeGestureRecognizer: UISwipeGestureRecognizer = {
    let gestureRecognizer = UISwipeGestureRecognizer()
    gestureRecognizer.direction = .right
    return gestureRecognizer
  }()

  // MARK: UICollectionView

  init() {
    let layout = TimelineCollectionViewFlowLayout()
    super.init(frame: CGRect.zero, collectionViewLayout: layout)
    showsHorizontalScrollIndicator = false
    backgroundColor = UIColor.white
    register(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))

    addGestureRecognizer(leftSwipeGestureRecognizer)
    leftSwipeGestureRecognizer.addTarget(self, action: #selector(TimelineCollectionView.leftSwipeGestureRecognizerSwiped))

    addGestureRecognizer(rightSwipeGestureRecognizer)
    rightSwipeGestureRecognizer.addTarget(self, action: #selector(TimelineCollectionView.rightSwipeGestureRecognizerSwiped))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  @objc fileprivate func leftSwipeGestureRecognizerSwiped() {
    if !isScrollEnabled {
      timelineDelegate?.timelineCollectionViewSwipedLeft(self)
    }
  }

  @objc fileprivate func rightSwipeGestureRecognizerSwiped() {
    if !isScrollEnabled {
      timelineDelegate?.timelineCollectionViewSwipedRight(self)
    }
  }
}

// MARK: - TimelineCollectionViewDelegate
protocol TimelineCollectionViewDelegate {
  func timelineCollectionViewSwipedLeft(_ collectionView: TimelineCollectionView)
  func timelineCollectionViewSwipedRight(_ collectionView: TimelineCollectionView)
}

// MARK: - TimelineCollectionViewFlowLayout
class TimelineCollectionViewFlowLayout: UICollectionViewFlowLayout {

  // MARK: Properties

  var delegate: TimelineCollectionViewFlowLayoutDelegate?

  fileprivate var updateItems = [UICollectionViewUpdateItem]()

  // MARK: Initializers

  override init() {
    super.init()
    scrollDirection = .horizontal
    minimumInteritemSpacing = 0
    minimumLineSpacing = 0
    itemSize = ClipCollectionViewCell.defaultSize
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UICollectionViewFlowLayout

  override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
    super.prepare(forCollectionViewUpdates: updateItems)

    self.updateItems = updateItems
  }

  override func finalizeCollectionViewUpdates() {
    super.finalizeCollectionViewUpdates()
    delegate?.timelineCollectionViewFlowLayout(self, willFinalizeCollectionViewUpdates: updateItems)
    updateItems.removeAll()
  }
}

protocol TimelineCollectionViewFlowLayoutDelegate {
  func timelineCollectionViewFlowLayout(_ layout: TimelineCollectionViewFlowLayout, willFinalizeCollectionViewUpdates updates: [UICollectionViewUpdateItem])
}
