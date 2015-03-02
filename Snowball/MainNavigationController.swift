//
//  MainNavigationController.swift
//  Snowball
//
//  Created by James Martinez on 1/14/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

  // MARK: - Initializers

  override init() {
    super.init(rootViewController: ClipsViewController())
    navigationBarHidden = true
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(nibName: String?, bundle: NSBundle?) {
    super.init(nibName: nibName, bundle: bundle)
  }
}