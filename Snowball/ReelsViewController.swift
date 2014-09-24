//
//  ReelsViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class ReelsViewController: ManagedTableViewController {
  private let topView = TopMediaView()

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerClass(ReelTableViewCell.self, forCellReuseIdentifier: ReelTableViewCell.identifier)

    let cameraViewController = CameraViewController()
    addChildViewController(cameraViewController)
    topView.cameraView = cameraViewController.view as CameraView
    view.addSubview(topView)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    layout(topView) { (topView) in
      topView.top == topView.superview!.top
      topView.bottom == topView.top + Float(UIScreen.mainScreen().bounds.width)
      topView.left == topView.superview!.left
      topView.right == topView.superview!.right
    }
    layout(tableView, topView) { (tableView, topView) in
      tableView.top == topView.bottom
      tableView.bottom == tableView.superview!.bottom
      tableView.left == tableView.superview!.left
      tableView.right == tableView.superview!.right
    }
  }

  // MARK: ManagedViewController

  override func objects() -> RLMArray {
    return Reel.allObjects()
  }

  override func reloadData() {
    API.getReelStream { (error) -> () in
      if error != nil { error?.display(); return }
      self.tableView.reloadData()
    }
  }

  // MARK: ManagedTableViewController

  override func cellType() -> UITableViewCell.Type {
    return ReelTableViewCell.self
  }

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let reelCell = cell as ReelTableViewCell
    reelCell.selectionStyle = UITableViewCellSelectionStyle.None
    reelCell.configureForObject(objects().objectAtIndex(UInt(indexPath.row)))
  }

  // MARK: UITableViewDataSource

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return ReelTableViewCell.height
  }

  // MARK: UITableViewDelegate

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let reelCell = tableView.cellForRowAtIndexPath(indexPath) as ReelTableViewCell
    let reel = objects().objectAtIndex(UInt(indexPath.row)) as Reel
    reelCell.showPlaybackIndicatorView()
    topView.playerView.playVideoURL(NSURL(string: reel.recentClip()!.videoURL)) {
      reelCell.hidePlaybackIndicatorView()
    }
  }
}