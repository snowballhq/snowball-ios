//
//  TimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import RealmSwift
import SwiftFetchedResultsController
import UIKit

class TimelineViewController: UIViewController {

  // MARK: Properties

  let timeline = Timeline(type: .Home)
  let player: TimelinePlayer
  let playerView = PlayerView()
  let timelineCollectionView = TimelineCollectionView()
  let fetchedResultsController: FetchedResultsController<Clip> = {
    let fetchRequest = FetchRequest<Clip>(realm: Database.realm, predicate: NSPredicate(value: true))
    fetchRequest.sortDescriptors = [SortDescriptor(property: "createdAt", ascending: true)]
    return FetchedResultsController<Clip>(fetchRequest: fetchRequest, sectionNameKeyPath: nil, cacheName: nil)
  }()
  var collectionViewUpdates = [NSBlockOperation]()
  var currentPage = 0

  // MARK: Initializers

  init() {
    player = TimelinePlayer(timeline: timeline)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(playerView)
    constrain(playerView) { playerView in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.height == playerView.superview!.width
    }
    player.delegate = self
    playerView.player = player

    view.addSubview(timelineCollectionView)
    constrain(timelineCollectionView, playerView) { timelineCollectionView, playerView in
      timelineCollectionView.left == timelineCollectionView.superview!.left
      timelineCollectionView.top == playerView.bottom
      timelineCollectionView.right == timelineCollectionView.superview!.right
      timelineCollectionView.bottom == timelineCollectionView.superview!.bottom
    }
    timelineCollectionView.dataSource = self
    timelineCollectionView.enablePullToLoadWithDelegate(self)

    fetchedResultsController.delegate = self
    fetchedResultsController.performFetch()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    requestRefreshOfClips()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    scrollToBookmarkedClip(false)
  }

  // MARK: - Private

  private func requestRefreshOfClips(completion: (() -> Void)? = nil) {
    currentPage = 1
    _requestClipsOnCurrentPage(completion)
  }

  private func requestNextPageOfClips(completion: (() -> Void)?) {
    currentPage++
    _requestClipsOnCurrentPage(completion)
  }

  private func _requestClipsOnCurrentPage(completion: (() -> Void)?) {
    let requestedPage = currentPage
    SnowballAPI.requestObjects(.GetClipStream(page: requestedPage)) { (response: ObjectResponse<[Clip]>) in
      switch response {
      case .Success(let clips):
        if requestedPage == 1 {
          self.deleteClipsNotInClips(clips)
        }
      case .Failure(let error): print(error) // TODO: Handle error
      }
      completion?()
    }
  }

  private func scrollToBookmarkedClip(animated: Bool) {
    if let bookmarkedClip = timeline.bookmarkedClip {
      scrollToCellForClip(bookmarkedClip, animated: animated)
    }
  }

  private func scrollToCellForClip(clip: Clip, animated: Bool) {
    if let indexPath = fetchedResultsController.indexPathForObject(clip) {
      timelineCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
    }
  }

  private func clipForCell(cell: ClipCollectionViewCell) -> Clip? {
    if let indexPath = timelineCollectionView.indexPathForCell(cell) {
      return fetchedResultsController.objectAtIndexPath(indexPath)
    }
    return nil
  }

  private func cellForClip(clip: Clip) -> ClipCollectionViewCell? {
    if let indexPath = fetchedResultsController.indexPathForObject(clip) {
      return timelineCollectionView.cellForItemAtIndexPath(indexPath) as? ClipCollectionViewCell
    }
    return nil
  }

  private func deleteClipsNotInClips(clips: [Clip]) {
    var clipIDs = [String]()
    for clip in clips {
      guard let clipID = clip.id else { break }
      clipIDs.append(clipID)
    }
    let clipsToDelete = Clip.findAll().filter("NOT id IN %@", clipIDs)
    Database.performTransaction {
      Database.realm.deleteWithNotification(clipsToDelete)
    }
  }

  private func setStateToPlayingClipForVisibleCells(clip: Clip) {
    let playingClipCell = cellForClip(clip)
    for cell in timelineCollectionView.visibleCells() as! [ClipCollectionViewCell] {
      let state: ClipCollectionViewCellState = (cell == playingClipCell) ? .PlayingActive : .PlayingIdle
      cell.setState(state, animated: true)
    }
  }

  private func updateStateForCell(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell) else { return }
    cell.setState(cellStateForClip(clip), animated: true)
  }

  private func updateStateForVisibleCells() {
    for cell in timelineCollectionView.visibleCells() as! [ClipCollectionViewCell] {
      updateStateForCell(cell)
    }
  }

  private func cellStateForClip(clip: Clip) -> ClipCollectionViewCellState {
    var state = ClipCollectionViewCellState.Default
    if clip == timeline.bookmarkedClip {
      state = .Bookmarked
    }
    if player.playing {
      if player.currentClip == clip {
        state = .PlayingActive
      } else {
        state = .PlayingIdle
      }
    }
    return state
  }
}

// MARK: - UICollectionViewDataSource
extension TimelineViewController: UICollectionViewDataSource {

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return fetchedResultsController.numberOfSections()
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.numberOfRowsForSectionIndex(section)
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ClipCollectionViewCell), forIndexPath: indexPath) as! ClipCollectionViewCell
    if let clip = fetchedResultsController.objectAtIndexPath(indexPath) {
      cell.configueForClip(clip, state: cellStateForClip(clip))
    }
    cell.delegate = self
    return cell
  }
}

// MARK: - FetchedResultsControllerDelegate
extension TimelineViewController: FetchedResultsControllerDelegate {

  func controllerWillChangeContent<T: Object>(controller: FetchedResultsController<T>) {
    collectionViewUpdates.removeAll()
  }

  func controllerDidChangeSection<T: Object>(controller: FetchedResultsController<T>, section: FetchResultsSectionInfo<T>, sectionIndex: UInt, changeType: NSFetchedResultsChangeType) {
    let section = NSIndexSet(index: Int(sectionIndex))
    collectionViewUpdates.append(NSBlockOperation {
      switch changeType {
      case .Insert:
        self.timelineCollectionView.insertSections(section)
      case .Delete:
        self.timelineCollectionView.deleteSections(section)
      case .Update, .Move:
        self.timelineCollectionView.reloadSections(section)
      }
      }
    )
  }

  func controllerDidChangeObject<T: Object>(controller: FetchedResultsController<T>, anObject object: SafeObject<T>, indexPath: NSIndexPath?, changeType: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    collectionViewUpdates.append(NSBlockOperation {
      switch changeType {
      case .Insert:
        self.timelineCollectionView.insertItemsAtIndexPaths([newIndexPath!])
      case .Delete:
        self.timelineCollectionView.deleteItemsAtIndexPaths([indexPath!])
      case .Update:
        self.timelineCollectionView.reloadItemsAtIndexPaths([indexPath!])
      case .Move:
        self.timelineCollectionView.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
      }
      }
    )
  }

  func controllerDidChangeContent<T: Object>(controller: FetchedResultsController<T>) {
    timelineCollectionView.performBatchUpdates({
      for updateClosure in self.collectionViewUpdates {
        updateClosure.start()
      }
      }, completion: { _ in
        if self.collectionViewUpdates.count > 0 {
          self.updateStateForVisibleCells()
          self.scrollToBookmarkedClip(true)
        }
    })
  }
}

// MARK: - TimelinePlayerDelegate
extension TimelineViewController: TimelinePlayerDelegate {
  func timelinePlayerShouldBeginPlayback(timelinePlayer: TimelinePlayer) -> Bool {
    return true
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip) {
    print("will begin")
    scrollToCellForClip(clip, animated: true)
    setStateToPlayingClipForVisibleCells(clip)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlaybackWithFirstClip clip: Clip) {}

  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip) {
    print("did transition")
    scrollToCellForClip(toClip, animated: true)
    player.queueManager.ensurePlayerQueueToppedOff()
    updateStateForVisibleCells()
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    print("did end")
    timeline.bookmarkedClip = clip
    updateStateForVisibleCells()
  }
}

// MARK: - ClipCollectionViewCellDelegate
extension TimelineViewController: ClipCollectionViewCellDelegate {
  func clipCollectionViewCellPlayButtonTapped(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell) else { player.stop(); return }
    if player.playing {
      if clip == player.currentClip {
        player.stop()
        return
      } else {
        player.pause()
        player.removeAllItemsExceptCurrentItem()
        player.queueManager.preparePlayerQueueToSkipToClip(clip) {
          self.player.advanceToNextItem()
          self.player.play()
        }
      }
    } else {
      player.queueManager.preparePlayerQueueToPlayClip(clip) {
        self.player.play()
      }
    }
  }
}

// MARK: - UIScrollViewPullToLoadDelegate
extension TimelineViewController: UIScrollViewPullToLoadDelegate {
  func scrollViewDidPullToLoad(scrollView: UIScrollView) {
    requestNextPageOfClips {
      scrollView.stopPullToLoadAnimation()
    }
  }
}