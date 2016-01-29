//
//  FriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/28/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

class FriendsViewController: UIViewController {

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("Friends", comment: "")
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-camera-outline"), style: .Plain, target: self, action: "leftBarButtonItemPressed")
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-add-friends"), style: .Plain, target: self, action: "rightBarButtonItemPressed")
  }

  // MARK: Actions

  @objc private func leftBarButtonItemPressed() {
    AppDelegate.sharedInstance.window?.transitionRootViewControllerToViewController(HomeNavigationController())
  }

  @objc private func rightBarButtonItemPressed() {
    print("NOT IMPLEMENTED: rightBarButtonItemPressed")
  }
}