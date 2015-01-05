//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

class Clip: RemoteObject {
  @NSManaged var id: String?
  @NSManaged var videoURL: String
  @NSManaged var createdAt: NSDate
  @NSManaged var played: NSNumber
  @NSManaged var user: User

  // MARK: - NSManagedObject

  override func assign(attributes: AnyObject) {
    if let id = attributes["id"] as? String {
      self.id = id
    }
    if let videoURL = attributes["video_url"] as? String {
      self.videoURL = videoURL
    }
    if let createdAt = attributes["created_at"] as? NSTimeInterval {
      self.createdAt = NSDate(timeIntervalSince1970: createdAt)
    }
    if let userJSON: AnyObject = attributes["user"] {
      if let user = User.objectFromJSON(userJSON, context: managedObjectContext!) {
        self.user = user as User
      }
    }
  }

  // MARK: - Clip

  class func clipWithVideoURL(videoURL: NSURL) -> Clip {
    let predicate = NSPredicate(format: "videoURL == %@", videoURL.absoluteString!)
    let clip = Clip.findAll(predicate: predicate).first! as Clip
    return clip
  }

  class func lastPlayedClip() -> Clip? {
    let predicate = NSPredicate(format: "played == true")
    let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
    let clip = Clip.findAll(predicate: predicate, sortDescriptors: [sortDescriptor]).first as Clip?
    return clip
  }

  class func playableClips(since: NSDate = NSDate(timeIntervalSince1970: 0)) -> [Clip] {
    let predicate = NSPredicate(format: "videoURL != nil && createdAt >= %@", since)
    return Clip.findAll(predicate: predicate, sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)]) as [Clip]
  }
}