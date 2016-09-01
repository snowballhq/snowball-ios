//
//  TimelineDataCoordinator.swift
//  Snowball
//
//  Created by James Martinez on 9/1/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

class TimelineDataCoordinator: CollectionDataCoordinator<Clip> {

  // MARK: Properties

  private(set) var currentPage = 1

  // MARK: Initializers

  init() {
    super.init(cacheKey: "timeline")
  }

  // MARK: CollectionDataCoordinator

  override func refresh() {
    getClipStream(page: 1)
  }

  // MARK: Internal

  func loadPreviousPage() {
    getClipStream(page: currentPage + 1)
  }

  // MARK: Private

  private func getClipStream(page page: Int) {
    currentPage = page

    SnowballAPI.request(SnowballAPIRoute.ClipStream(page: page)).responseCollection { (response: Response<[Clip], NSError>) in
      switch response.result {
      case .Success(let clips):
        if page == 1 {
          self.updateData(clips.reverse())
        } else {
          self.updateData(self.data.mergedArrayByPrepending(clips.reverse()))
        }
      case .Failure(let error): debugPrint(error)
      }
    }
  }
}