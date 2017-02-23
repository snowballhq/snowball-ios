//
//  UserTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/17/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

class UserTimelineViewController: TimelineViewController {

  // MARK: Properties

  private let topBackgroundImageView = UIImageView()
  private let usernameLabel: UILabel
  private let followButton: UIButton
  private let user: User

  // MARK: Initializers

  init(user: User) {
    self.user = user
    usernameLabel = UILabel()
    followButton = UIButton(type: .Custom)
    super.init(timelineType: .User(userID: user.id ?? ""))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topBackgroundImageView)
    constrain(topBackgroundImageView) { topBackgroundImageView in
      topBackgroundImageView.left == topBackgroundImageView.superview!.left
      topBackgroundImageView.top == topBackgroundImageView.superview!.top
      topBackgroundImageView.right == topBackgroundImageView.superview!.right
      topBackgroundImageView.height == topBackgroundImageView.superview!.width
    }
    if let avatarURLString = user.avatarURL, avatarURL = NSURL(string: avatarURLString) {
      topBackgroundImageView.setImageFromURL(avatarURL)
    }

    let followImage = user.following ? UIImage(imageLiteral: "button-following") : UIImage(imageLiteral: "button-follow")
    followButton.setBackgroundImage(followImage, forState: .Normal)
    let contentSize = followButton.intrinsicContentSize()
    let followButtonAspectRatio = contentSize.height / contentSize.width
    view.addSubview(followButton)

    constrain(followButton, topBackgroundImageView) { followButton, topBackgroundImageView in
      followButton.height == followButton.width * followButtonAspectRatio
      followButton.width == 110
      followButton.bottom == topBackgroundImageView.bottom - 20
      followButton.centerX == topBackgroundImageView.centerX
    }

    usernameLabel.font = UIFont.SnowballFont.mediumFont.fontWithSize(30)
    usernameLabel.textAlignment = .Center
    usernameLabel.text = user.username
    usernameLabel.textColor = UIColor.whiteColor()
    view.addSubview(usernameLabel)

    let height = usernameLabel.sizeThatFits(CGSize(width: view.bounds.width, height: CGFloat.max)).height

    constrain(usernameLabel, topBackgroundImageView, followButton) { usernameLabel, topBackgroundImageView, followButton in
      usernameLabel.height == height
      usernameLabel.width == topBackgroundImageView.width
      usernameLabel.bottom == followButton.top - 20
      usernameLabel.centerX == topBackgroundImageView.centerX
    }
  }

  // MARK: TimelinePlayerDelegate Overrides
  // This is because swift does not allow overrides in extensions. Sorry!

  override func timelinePlayer(timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip) {
    super.timelinePlayer(timelinePlayer, willBeginPlaybackWithFirstClip: clip)
    view.sendSubviewToBack(topBackgroundImageView)
  }

  override func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    super.timelinePlayer(timelinePlayer, didEndPlaybackWithLastClip: clip)
    view.bringSubviewToFront(topBackgroundImageView)
  }
}
