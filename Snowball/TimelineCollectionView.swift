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

  private let leftSwipeGestureRecognizer: UISwipeGestureRecognizer = {
    let gestureRecognizer = UISwipeGestureRecognizer()
    gestureRecognizer.direction = .Left
    return gestureRecognizer
  }()

  private let rightSwipeGestureRecognizer: UISwipeGestureRecognizer = {
    let gestureRecognizer = UISwipeGestureRecognizer()
    gestureRecognizer.direction = .Right
    return gestureRecognizer
  }()

  // MARK: UICollectionView

  init() {
    let layout = TimelineCollectionViewFlowLayout()
    super.init(frame: CGRectZero, collectionViewLayout: layout)
    showsHorizontalScrollIndicator = false
    backgroundColor = UIColor.whiteColor()
    registerClass(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))

    addGestureRecognizer(leftSwipeGestureRecognizer)
    leftSwipeGestureRecognizer.addTarget(self, action: "leftSwipeGestureRecognizerSwiped")

    addGestureRecognizer(rightSwipeGestureRecognizer)
    rightSwipeGestureRecognizer.addTarget(self, action: "rightSwipeGestureRecognizerSwiped")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  @objc private func leftSwipeGestureRecognizerSwiped() {
    if !scrollEnabled {
      timelineDelegate?.timelineCollectionViewSwipedLeft(self)
    }
  }

  @objc private func rightSwipeGestureRecognizerSwiped() {
    if !scrollEnabled {
      timelineDelegate?.timelineCollectionViewSwipedRight(self)
    }
  }
}

// MARK: - TimelineCollectionViewDelegate
protocol TimelineCollectionViewDelegate {
  func timelineCollectionViewSwipedLeft(collectionView: TimelineCollectionView)
  func timelineCollectionViewSwipedRight(collectionView: TimelineCollectionView)
}

// MARK: - TimelineCollectionViewFlowLayout
class TimelineCollectionViewFlowLayout: UICollectionViewFlowLayout {

  // MARK: Properties

  private var shouldOverrideScrollPosition = false

  // MARK: Initializers

  override init() {
    super.init()
    scrollDirection = .Horizontal
    minimumInteritemSpacing = 0
    minimumLineSpacing = 0
    itemSize = ClipCollectionViewCell.defaultSize
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UICollectionViewFlowLayout

  override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
    super.prepareForCollectionViewUpdates(updateItems)

    for updateItem in updateItems {
      // TODO: All scroll related actions should be handled here (bookmarks!)
      if updateItem.updateAction == .Insert {
        shouldOverrideScrollPosition = true
      }
    }
  }

  override func finalizeCollectionViewUpdates() {
    super.finalizeCollectionViewUpdates()

    if shouldOverrideScrollPosition {
      guard let collectionView = collectionView else { return }
      let contentSizeBeforeAnimation = collectionView.contentSize
      let contentSizeAfterAnimation = collectionViewContentSize()
      let xOffset = contentSizeAfterAnimation.width - contentSizeBeforeAnimation.width
      if xOffset < 0 {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
      } else {
        collectionView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
      }
      shouldOverrideScrollPosition = false
    }
  }
}