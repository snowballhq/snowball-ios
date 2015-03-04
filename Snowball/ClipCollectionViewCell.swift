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

class ClipCollectionViewCell: UICollectionViewCell {

  // MARK: - Properties

  class var size: CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    return CGSizeMake(140.0, cellHeight)
  }

  private let clipThumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    return imageView
  }()

  private let clipThumbnailLoadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

  private let addClipImageView = UIImageView(image: UIImage(named: "add-clip"))

  private let userAvatarImageView = UserAvatarImageView()

  private let usernameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.bold, size: 17)
    label.textAlignment = NSTextAlignment.Center
    return label
  }()

  private let clipTimeLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 12)
    label.textAlignment = NSTextAlignment.Center
    label.textColor = UIColor(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1.0)
    return label
  }()

  private let dimView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.whiteColor()
    view.alpha = 0.6
    view.hidden = true
    return view
  }()

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(clipThumbnailImageView)
    clipThumbnailImageView.addSubview(clipThumbnailLoadingIndicator)
    clipThumbnailImageView.addSubview(addClipImageView)
    contentView.addSubview(userAvatarImageView)
    contentView.addSubview(usernameLabel)
    contentView.addSubview(clipTimeLabel)
    contentView.addSubview(dimView)
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

    layout(clipThumbnailLoadingIndicator) { (clipThumbnailLoadingIndicator) in
      clipThumbnailLoadingIndicator.left == clipThumbnailLoadingIndicator.superview!.left
      clipThumbnailLoadingIndicator.top == clipThumbnailLoadingIndicator.superview!.top
      clipThumbnailLoadingIndicator.right == clipThumbnailLoadingIndicator.superview!.right
      clipThumbnailLoadingIndicator.height == clipThumbnailLoadingIndicator.superview!.width
    }

    addClipImageView.frame = clipThumbnailImageView.bounds

    layout(userAvatarImageView, clipThumbnailImageView) { (userAvatarImageView, clipThumbnailImageView) in
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.top == clipThumbnailImageView.bottom + 10
      userAvatarImageView.width == 40
      userAvatarImageView.height == userAvatarImageView.width
    }

    layout(usernameLabel, userAvatarImageView) { (usernameLabel, userAvatarImageView) in
      usernameLabel.left == usernameLabel.superview!.left
      usernameLabel.top == userAvatarImageView.bottom + 5
      usernameLabel.right == usernameLabel.superview!.right
    }

    layout(clipTimeLabel, usernameLabel) { (clipTimeLabel, usernameLabel) in
      clipTimeLabel.left == clipTimeLabel.superview!.left
      clipTimeLabel.top == usernameLabel.bottom + 2
      clipTimeLabel.right == clipTimeLabel.superview!.right
    }

    dimView.frame = contentView.bounds
  }

  // MARK: - Internal

  func configureForClip(clip: Clip) {
    usernameLabel.text = clip.user?.username
    let userColor = clip.user?.color as? UIColor ?? UIColor.SnowballColor.greenColor
    if let user = clip.user {
      userAvatarImageView.configureForUser(user)
    }
    usernameLabel.textColor = userColor
    clipTimeLabel.text = clip.createdAt?.shortTimeSinceString()

    clipThumbnailImageView.image = UIImage()
    if let thumbnailURL = clip.thumbnailURL {
      if thumbnailURL.scheme == "file" {
        let imageData = NSData(contentsOfURL: thumbnailURL)!
        let image = UIImage(data: imageData)
        clipThumbnailImageView.image = image
      } else {
        clipThumbnailLoadingIndicator.startAnimating()
        clipThumbnailImageView.hnk_setImageFromURL(thumbnailURL, format: Format<UIImage>(name: "original"), failure: { _ in
          self.clipThumbnailLoadingIndicator.stopAnimating()
        }, success: { (image) in
          self.clipThumbnailImageView.image = image
          self.clipThumbnailLoadingIndicator.stopAnimating()
        })
      }
    }
    setInPlayState(false, isPlayingClip: false, animated: false)
    if clip.state == ClipState.Pending {
      addClipImageView.hidden = false
    } else {
      addClipImageView.hidden = true
    }
  }

  func setInPlayState(inPlayState: Bool, isPlayingClip: Bool, animated: Bool = true) {
    scaleClipThumbnail(inPlayState, animated: animated)
    let shouldDimContentView = (inPlayState && !isPlayingClip)
    dimContentView(shouldDimContentView)
  }

  // MARK: - Private

  private func dimContentView(dim: Bool) {
    dimView.hidden = !dim
  }

  private func scaleClipThumbnail(down: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.scaleClipThumbnail(down, animated: false)
      }
    } else {
      if down {
        clipThumbnailImageView.transform = CGAffineTransformMakeScale(0.85, 0.85)
      } else {
        clipThumbnailImageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
      }
    }
  }
}
