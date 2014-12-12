//
//  HomeViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class HomeViewController: UIViewController {
  let playerViewController = PlayerViewController()
  let cameraViewController = UIViewController() // TODO: use real vc
  let clipsViewController = ClipsViewController()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    addChildViewController(playerViewController) {
      layout(self.playerViewController.view) { (playerViewControllerView) in
        playerViewControllerView.left == playerViewControllerView.superview!.left
        playerViewControllerView.top == playerViewControllerView.superview!.top
        playerViewControllerView.right == playerViewControllerView.superview!.right
        playerViewControllerView.height == playerViewControllerView.superview!.width
      }
    }

    addChildViewController(cameraViewController) {
      self.cameraViewController.view.frame = self.playerViewController.view.frame
    }

    addChildViewController(clipsViewController) {
      layout(self.clipsViewController.view, self.playerViewController.view) { (clipsViewControllerView, playerViewControllerView) in
        clipsViewControllerView.left == clipsViewControllerView.superview!.left
        clipsViewControllerView.top == playerViewControllerView.bottom
        clipsViewControllerView.right == clipsViewControllerView.superview!.right
        clipsViewControllerView.bottom == clipsViewControllerView.superview!.bottom
      }
    }

    // TODO: remove this. This is just for testing.
    let URL = NSURL(string: "http://techslides.com/demos/sample-videos/small.mp4")!
    playerViewController.playURLs([URL, URL])
  }
}
