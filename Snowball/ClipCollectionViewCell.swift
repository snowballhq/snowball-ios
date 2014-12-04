//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 12/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ClipCollectionViewCell: UICollectionViewCell {

  // MARK: - UICollectionViewCell+Required

  override class func size() -> CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    return CGSizeMake((screenWidth/2) - (screenWidth/20), cellHeight)
  }

  override func configureForObject(object: AnyObject) {}
}
