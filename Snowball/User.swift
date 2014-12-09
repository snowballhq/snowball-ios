//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData
import UIKit

class User: NSManagedObject {
  @NSManaged var id: String
  @NSManaged var name: String
  @NSManaged var username: String
  @NSManaged var avatarURL: String
  @NSManaged var following: NSNumber
  @NSManaged var clips: NSSet
  @NSManaged var color: AnyObject

  // MARK: - NSManageObject

  override func awakeFromInsert() {
    super.awakeFromInsert()
    color = UIColor.SnowballColor.randomColor()
  }
}