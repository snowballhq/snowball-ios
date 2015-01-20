//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 12/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import Haneke
import UIKit

protocol ClipCollectionViewCellDelegate: class {
  func playClipButtonTappedInCell(cell: ClipCollectionViewCell)
}

class ClipCollectionViewCell: UICollectionViewCell {
  var delegate: ClipCollectionViewCellDelegate?
  private let clipThumbnailImageView = UIImageView()
  private let userAvatarImageView = UserAvatarImageView()
  private let userNameLabel = UILabel()
  private let clipTimeLabel = UILabel()
  let playButton = UIButton()
  let pauseButton = UIButton()
  let addButton = UIButton()

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipThumbnailImageView.backgroundColor = UIColor.blackColor()
    contentView.addSubview(clipThumbnailImageView)
    contentView.addSubview(userAvatarImageView)
    userNameLabel.font = UIFont(name: UIFont.SnowballFont.bold, size: 18)
    userNameLabel.textAlignment = NSTextAlignment.Center
    contentView.addSubview(userNameLabel)
    clipTimeLabel.font = UIFont(name: "Helvetica-Bold", size: 16)
    clipTimeLabel.textAlignment = NSTextAlignment.Center
    clipTimeLabel.textColor = UIColor(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1.0)
    contentView.addSubview(clipTimeLabel)
    playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
    playButton.addTarget(self, action: "playClip", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(playButton)
    pauseButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
    contentView.addSubview(pauseButton)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    layout(clipThumbnailImageView) { (clipThumbnailImageView) in
      clipThumbnailImageView.left == clipThumbnailImageView.superview!.left
      clipThumbnailImageView.top == clipThumbnailImageView.superview!.top
      clipThumbnailImageView.right == clipThumbnailImageView.superview!.right
      clipThumbnailImageView.height == clipThumbnailImageView.superview!.width
    }

    layout(userAvatarImageView, clipThumbnailImageView) { (userAvatarImageView, clipThumbnailImageView) in
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.top == clipThumbnailImageView.bottom + 10
      userAvatarImageView.width == 40
      userAvatarImageView.height == userAvatarImageView.width
    }

    layout(userNameLabel, userAvatarImageView) { (userNameLabel, userAvatarImageView) in
      userNameLabel.left == userNameLabel.superview!.left
      userNameLabel.top == userAvatarImageView.bottom + 5
      userNameLabel.right == userNameLabel.superview!.right
    }

    layout(clipTimeLabel, userNameLabel) { (clipTimeLabel, userNameLabel) in
      clipTimeLabel.left == clipTimeLabel.superview!.left
      clipTimeLabel.top == userNameLabel.bottom + 2
      clipTimeLabel.right == clipTimeLabel.superview!.right
    }

    playButton.frame = clipThumbnailImageView.frame
    pauseButton.frame = clipThumbnailImageView.frame
    addButton.frame = clipThumbnailImageView.frame
  }

  // MARK: - UICollectionReuseableView+Required

  override class func size() -> CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    return CGSizeMake(140.0, cellHeight)
  }

  override func configureForObject(object: AnyObject) {
    let clip = object as Clip
    if clip.id != nil {
      let user = clip.user
      userNameLabel.text = user.username
      let userColor = user.color as UIColor
      userAvatarImageView.backgroundColor = userColor
      userNameLabel.textColor = userColor
      clipTimeLabel.text = clip.createdAt.shortTimeSinceString()

      clipThumbnailImageView.hnk_setImageFromURL(NSURL(string: clip.thumbnailURL)!, format: Format<UIImage>(name: "original"))

      if clip.played.boolValue {
        clipThumbnailImageView.alpha = 0.5
      } else {
        clipThumbnailImageView.alpha = 1.0
      }
      playButton.hidden = false
      pauseButton.hidden = true
      addButton.hidden = true
    } else {
      playButton.hidden = true
      pauseButton.hidden = true
      addButton.hidden = false
    }
  }
  
  // MARK: - Actions

  func playClip() {
    delegate?.playClipButtonTappedInCell(self)
  }

  // MARK: - Public

  func scaleClipThumbnail(down: Bool, animated: Bool) {
    let scaleBlock: () -> () = {
      var scale: CGFloat = 1.0
      if down {
        scale = 0.9
      }
      self.clipThumbnailImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale)
    }
    if animated {
      UIView.animateWithDuration(0.1) {
        scaleBlock()
      }
      return
    }
    scaleBlock()
  }
}
