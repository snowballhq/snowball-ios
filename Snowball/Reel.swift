//
//  Reel.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class Reel: RLMObject, JSONObjectSerializable, JSONArraySerializable {
  dynamic var id = ""
  dynamic var title = ""
  dynamic var participantsTitle = ""
  dynamic var lastWatchedClip: Clip?

  func clips() -> RLMArray {
    return Clip.objectsInRealm(realm, withPredicate: NSPredicate(format: "reel == %@", self))
  }

  func recentClip() -> Clip? {
    return clips().arraySortedByProperty("createdAt", ascending: false).firstObject() as Clip?
  }

  func playableClips() -> RLMArray {
    if let clip = lastWatchedClip {
      return clips().objectsWithPredicate(NSPredicate(format: "createdAt >= %@", clip.createdAt))
    }
    return clips()
  }

  // MARK: JSONObjectSerializable

  class func objectFromJSON(JSON: [String: AnyObject]) -> AnyObject {
    var reel: Reel? = nil
    if let id = JSON["id"] as AnyObject? as? String {
      if let existingReel = Reel.findByID(id) as? Reel{
        reel = existingReel
      } else {
        reel!.id = id
      }
    }
    if let title = JSON["title"] as AnyObject? as? String {
      reel!.title = title
    }
    if let participantsTitle = JSON["participants_title"] as AnyObject? as? String {
      reel!.participantsTitle = participantsTitle
    }
    if let recentClipJSON = JSON["recent_clip"] as AnyObject? as [String: AnyObject]? {
      Clip.objectFromJSON(recentClipJSON)
    }
    return reel!
  }

  // MARK: JSONArraySerializable

  class func arrayFromJSON(JSON: [String: AnyObject]) -> [AnyObject] {
    var reels = [AnyObject]()
    if let reelsJSON = JSON["reels"] as AnyObject? as? [AnyObject] {
      for JSONObject in reelsJSON {
        if let reelJSON = JSONObject as AnyObject? as? [String: AnyObject] {
          reels.append(Reel.objectFromJSON(reelJSON))
        }
      }
    }
    return reels
  }
}