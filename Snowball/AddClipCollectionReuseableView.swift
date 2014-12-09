//
//  AddClipCollectionReuseableView.swift
//  Snowball
//
//  Created by James Martinez on 12/5/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

protocol AddClipCollectionReuseableViewDelegate: class {
  func addClipButtonTapped()
}

class AddClipCollectionReuseableView: UICollectionReusableView {
  var delegate: AddClipCollectionReuseableViewDelegate?
  var addClipButton = UIButton()

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    addClipButton.setImage(UIImage(named: "add-clip"), forState: UIControlState.Normal)
    addClipButton.addTarget(delegate, action: "addClipButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(addClipButton)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    layout(addClipButton) { (addClipButton) in
      addClipButton.left == addClipButton.superview!.left
      addClipButton.top == addClipButton.superview!.top
      addClipButton.width == addClipButton.superview!.width
      addClipButton.height == addClipButton.superview!.width
    }
  }

  // MARK: - UICollectionReuseableView+Required

  override class func size() -> CGSize {
    return ClipCollectionViewCell.size()
  }

}
