//
//  MainTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 7/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class MainTimelineViewController: TimelineViewController {

  // MARK: - Properties

  private let cameraViewController = CameraViewController()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraViewController.delegate = self

    timeline.loadCachedClips()
  }

  override func loadView() {
    super.loadView()

    addChildViewController(cameraViewController)
    view.insertSubview(cameraViewController.view, belowSubview: playerView)
    cameraViewController.didMoveToParentViewController(self)
    constrain(cameraViewController.view) { (cameraView) in
      cameraView.left == cameraView.superview!.left
      cameraView.top == cameraView.superview!.top
      cameraView.right == cameraView.superview!.right
      cameraView.height == cameraView.width
    }

    topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Friends, rightButtonType: SnowballTopViewButtonType.ChangeCamera)
    view.addSubview(topView)
    topView.setupDefaultLayout()
  }

  // MARK: - TimelineViewController

  override func loadPage(page: Int) {
    timeline.requestHomeTimeline(page: page) { (error) -> Void in
      error?.alertUser()
    }
  }

  override func stateForCellAtIndexPath(indexPath: NSIndexPath) -> ClipCollectionViewCellState {
    let superState = super.stateForCellAtIndexPath(indexPath)
    if superState != ClipCollectionViewCellState.Default {
      return superState
    }
    let clip = timeline.clips[indexPath.row]
    if let bookmarkedClip = timeline.bookmarkedClip {
      if clip == bookmarkedClip {
        return ClipCollectionViewCellState.Bookmarked
      }
    }
    return superState
  }

  // MARK: - TimelineDelegate
  // See the comment in TimelineViewController for the TimelinePlayer delegate
  // to see why this is here. It's such a confusing mess. Sorry future self!
  override func timelineClipsDidLoadFromCache() {
    super.timelineClipsDidLoadFromCache()

    collectionView.layoutIfNeeded() // Hack to ensure that the scrolling will take place

    scrollToPendingOrBookmark(false)
  }

  // MARK: - TimelinePlayerDelegate
  // See the comment in TimelineViewController for the TimelinePlayer delegate
  // to see why this is here. It's such a confusing mess. Sorry future self!
  override func timelinePlayer(timelinePlayer: TimelinePlayer, shouldBeginPlayingWithClip clip: Clip) -> Bool {
    super.timelinePlayer(timelinePlayer, shouldBeginPlayingWithClip: clip)
    return cameraViewController.state == CameraViewControllerState.Default
  }

  // MARK: - TimelineFlowLayoutDelegate
  override func timelineFlowLayoutDidFinalizeCollectionViewUpdates(layout: TimelineFlowLayout) {
    super.timelineFlowLayoutDidFinalizeCollectionViewUpdates(layout)

    scrollToPendingOrBookmark(false)
  }

  // MARK: - Private

  private func scrollToPendingOrBookmark(animated: Bool) {
    if player.playing { return }
    if let pendingClip = timeline.pendingClips.last {
      scrollToClip(pendingClip, animated: animated)
    } else if let bookmarkedClip = timeline.bookmarkedClip {
      scrollToClip(bookmarkedClip, animated: animated)
    }
  }
}

// MARK: - ClipCollectionViewCellDelegate
extension MainTimelineViewController {

  override func userDidTapAddButtonForCell(cell: ClipCollectionViewCell) {
    authenticateUser {
      Analytics.track("Create Clip")
      self.setInterfaceFocused(false)
      self.cameraViewController.endPreview()
      self.uploadClipForCell(cell)
    }
  }

  override func userDidTapUserButtonForCell(cell: ClipCollectionViewCell) {
    if cameraViewController.state == CameraViewControllerState.Default {
      super.userDidTapUserButtonForCell(cell)
    }
  }

  override func userDidTapUploadRetryButtonForCell(cell: ClipCollectionViewCell) {
    uploadClipForCell(cell)
  }

  private func uploadClipForCell(cell: ClipCollectionViewCell) {
    if let clip = clipForCell(cell) {
      clip.state = .Uploading
      timeline.markClipAsUpdated(clip)
      API.uploadClip(clip) { (request, response, JSON, error) -> () in
        if let error = error {
          error.alertUser()
          clip.state = ClipState.UploadFailed
        } else {
          clip.state = ClipState.Default
          if let JSON = JSON as? [String: AnyObject] {
            clip.assignAttributes(JSON)
          }
        }
        do { try clip.managedObjectContext?.save() } catch {}
        self.timeline.markClipAsUpdated(clip)
      }
    }
  }
}

// MARK: - CameraViewControllerDelegate
extension MainTimelineViewController: CameraViewControllerDelegate {

  func videoDidBeginRecording() {
    setInterfaceFocused(true)
  }

  func videoDidEndRecordingToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL) {
    let clip = Clip.newObject() as! Clip
    clip.state = ClipState.PendingUpload
    clip.videoURL = videoURL.absoluteString
    clip.thumbnailURL = thumbnailURL.absoluteString
    clip.user = User.currentUser
    clip.createdAt = NSDate()
    timeline.appendClip(clip)
    scrollToClip(clip, animated: true)
  }

  func videoPreviewDidCancel() {
    setInterfaceFocused(false)
    if let clip = timeline.pendingClips.last {
      timeline.deleteClip(clip)
    }
  }
}

// MARK: - SnowballTopViewDelegate
extension MainTimelineViewController: SnowballTopViewDelegate {

  func snowballTopViewLeftButtonTapped() {
    authenticateUser {
      self.switchToNavigationController(MoreNavigationController())
    }
  }

  func snowballTopViewRightButtonTapped() {
    cameraViewController.changeCamera()
  }
}