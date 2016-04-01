//
//  NSError+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension NSError {
  static func snowballErrorWithReason(reason: String?) -> NSError {
    let domain = "is.snowball.snowball.error"
    if let reason = reason {
      return NSError(domain: domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: reason])
    }
    return NSError(domain: domain, code: 0, userInfo: nil)
  }

  func displayToUserIfAppropriateFromViewController(sourceViewController: UIViewController) {
    print("Error: " + self.description)

    if domain == "is.snowball.snowball.error" {
      if let message = userInfo[NSLocalizedFailureReasonErrorKey] as? String where message.characters.count > 0 {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Cancel, handler: nil))
        sourceViewController.presentViewController(alertController, animated: true, completion: nil)
      }
    }
  }
}