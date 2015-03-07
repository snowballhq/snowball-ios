//
//  AuthenticationViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class AuthenticationViewController: UIViewController {

  // MARK: - Properties

  private let topBar = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: SnowballTopViewButtonType.Forward)

  let messageLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    label.numberOfLines = 2
    return label
  }()

  private let tableViewController = UITableViewController()

  var tableView: UITableView {
    return tableViewController.view as UITableView
  }

  var authenticationRoute: Router! { return nil }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topBar)
    topBar.setupDefaultLayout()

    tableView.allowsSelection = false
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.rowHeight = TextFieldTableViewCell.height
    tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextFieldTableViewCell))

    let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 70))
    let sideMargin: CGFloat = 25
    tableHeaderView.addSubview(messageLabel)
    layout(messageLabel) { (messageLabel) in
      messageLabel.left == messageLabel.superview!.left + sideMargin
      messageLabel.top == messageLabel.superview!.top
      messageLabel.right == messageLabel.superview!.right - sideMargin
    }
    tableView.tableHeaderView = tableHeaderView

    addChildViewController(tableViewController)
    view.addSubview(tableViewController.view)
    tableViewController.didMoveToParentViewController(self)
    layout(tableViewController.view, topBar) { (tableView, topBar) in
      tableView.left == tableView.superview!.left
      tableView.top == topBar.bottom
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }
  }

  // MARK: - Private

  private func performAuthenticationRequest() {
    API.request(authenticationRoute).responseJSON { (request, response, JSON, error) in
      if error != nil { displayAPIErrorToUser(JSON); return }
      if let userJSON: AnyObject = JSON {
        dispatch_async(dispatch_get_main_queue()) {
          let user = User.objectFromJSON(userJSON) as User?
          user?.managedObjectContext?.save(nil)
          User.currentUser = user
          if let userID = user?.id {
            // TODO: make this configurable by a block or something
            if self.isKindOfClass(SignUpViewController) {
              Analytics.createAliasAndIdentify(userID)
              Analytics.track("Sign Up")
              self.navigationController?.pushViewController(PhoneNumberViewController(), animated: true)
            } else {
              Analytics.identify(userID)
              Analytics.track("Sign In")
              self.switchToNavigationController(MainNavigationController())
            }
          }
        }
      }
    }
  }
}

// MARK: -

extension AuthenticationViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }

  func snowballTopViewRightButtonTapped() {
    performAuthenticationRequest()
  }
}