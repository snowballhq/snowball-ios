//
//  FindFriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/8/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AddressBook
import Cartography
import MessageUI
import UIKit

class FindFriendsViewController: UIViewController {

  // MARK: - Properties

  private let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: nil, title: NSLocalizedString("Find Friends", comment: ""))

  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.rowHeight = UserTableViewCell.height
    tableView.registerClass(UserTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UserTableViewCell))
    return tableView
    }()

  private let searchTextField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.font = UIFont(name: UIFont.SnowballFont.regular, size: 19)
    textField.tintColor = UIColor.blackColor()
    textField.returnKeyType = UIReturnKeyType.Search
    textField.autocapitalizationType = UITextAutocapitalizationType.None
    textField.autocorrectionType = UITextAutocorrectionType.No
    textField.rightViewMode = UITextFieldViewMode.Always
    return textField
    }()

  private let tableViewLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 17)
    return label
    }()

  private var searching: Bool = false {
    didSet {
      users = []
      tableView.reloadData()
      searchTextField.text = nil

      if searching {
        searchTextField.setPlaceholder("", color: UIColor.blackColor())
        tableViewLabel.text = NSLocalizedString("Find by username", comment: "")

        let cancelImage = UIImage(named: "search-cancel")!
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: cancelImage.size.width + 20, height: cancelImage.size.height))
        cancelButton.setImage(cancelImage, forState: UIControlState.Normal)
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        cancelButton.addTarget(self, action: "searchCancelButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        searchTextField.rightView = cancelButton
      } else {
        searchTextField.endEditing(true)

        searchTextField.setPlaceholder(NSLocalizedString("Search by username", comment: ""), color: UIColor.blackColor())
        tableViewLabel.text = NSLocalizedString("Friends from my address book", comment: "")

        let searchImage = UIImage(named: "search")!
        let searchImageView = UIImageView(image: searchImage)
        searchImageView.contentMode = UIViewContentMode.Left
        searchImageView.frame = CGRect(x: 0, y: 0, width: searchImage.size.width + 20, height: searchImage.size.height)
        searchTextField.rightView = searchImageView
      }
    }
  }

  private var users: [User] = []

  private let addressBook: ABAddressBook? = {
    var error: Unmanaged<CFError>?
    let addressBook = ABAddressBookCreateWithOptions(nil, &error)
    if error != nil {
      print("Address book creation error: \(error)")
      return nil
    }
    return addressBook.takeRetainedValue()
    }()

  private let footerButton: SnowballFooterButton = {
    let button = SnowballFooterButton(rightImage: UIImage(named: "plane"))
    button.setTitle(NSLocalizedString("Invite a friend", comment: ""), forState: UIControlState.Normal)
    return button
    }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    searchTextField.delegate = self
    view.addSubview(searchTextField)
    let margin: CGFloat = 20
    constrain(searchTextField, topView) { (searchTextField, topView) in
      searchTextField.left == searchTextField.superview!.left + margin
      searchTextField.top == topView.bottom
      searchTextField.right == searchTextField.superview!.right - margin
      searchTextField.height == 50
    }

    view.addSubview(tableViewLabel)
    constrain(tableViewLabel, searchTextField) { (tableViewLabel, searchTextField) in
      tableViewLabel.left == tableViewLabel.superview!.left + margin
      tableViewLabel.top == searchTextField.bottom + 15
      tableViewLabel.right == tableViewLabel.superview!.right - margin
    }

    searching = false // Sets tableViewLabel text

    view.addSubview(footerButton)
    footerButton.setupDefaultLayout()
    footerButton.addTarget(self, action: "footerButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)

    tableView.addRefreshControl(self, action: "refresh")
    tableView.dataSource = self
    tableView.delegate = self
    view.addSubview(tableView)
    constrain(tableView, tableViewLabel, footerButton) { (tableView, tableViewLabel, footerButton) in
      tableView.left == tableView.superview!.left
      tableView.top == tableViewLabel.bottom + 5
      tableView.right == tableView.superview!.right
      tableView.bottom == footerButton.top
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    tableView.beginRefreshingAnimation()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    ABAddressBookRequestAccessWithCompletion(addressBook) { (granted, error) in
      if granted {
        self.refresh()
      } else {
        self.accessUnauthorized()
      }
    }
  }

  // MARK: - Private

  private func accessUnauthorized() {
    tableView.endRefreshingAnimation()
    let error = NSError.snowballErrorWithReason(NSLocalizedString("Please go to Settings > Snowball > Contacts to allow Snowball to access your Contacts.", comment: ""))
    error.alertUser()
  }

  @objc private func refresh() {
    let authorizationStatus = ABAddressBookGetAuthorizationStatus()
    if authorizationStatus != ABAuthorizationStatus.Authorized {
      accessUnauthorized()
      return
    }
    var phoneNumbers = [String]()
    let contacts = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
    for contact in contacts {
      let phoneNumberProperty: AnyObject = ABRecordCopyValue(contact, kABPersonPhoneProperty).takeRetainedValue()
      for var i = 0; i < ABMultiValueGetCount(phoneNumberProperty); i++ {
        let phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumberProperty, i).takeRetainedValue() as! String
        phoneNumbers.append(phoneNumber)
      }
    }

    SnowballAPI.requestObjects(.FindUsersByPhoneNumbers(phoneNumbers: phoneNumbers)) { (response: ObjectResponse<[User]>) in
      switch response {
      case .Success(let users):
        self.users = users
        self.tableView.reloadData()
      case .Failure(let error): error.alertUser()
      }
      self.tableView.endRefreshingAnimation()
    }
  }

  private func searchForUserWithUsername(username: String) {
    tableView.beginRefreshingAnimation()
    SnowballAPI.requestObjects(.FindUsersByUsername(username: username)) { (response: ObjectResponse<[User]>) in
      switch response {
      case .Success(let users):
        self.users = users
        self.tableView.reloadData()
      case .Failure(let error):
        error.alertUser()
      }
      self.tableView.endRefreshingAnimation()
    }
  }

  @objc private func searchCancelButtonTapped() {
    cancelSearch()
  }

  private func cancelSearch() {
    searching = false
    refresh()
  }

  @objc private func footerButtonTapped() {
    let messageComposeViewController = MFMessageComposeViewController()
    messageComposeViewController.messageComposeDelegate = self
    var body = NSLocalizedString("Hey! Join me on the simple new video app, Snowball: http://bit.ly/snblapp.", comment: "")
    if let username = User.currentUser?.username {
      body += " " + NSLocalizedString("My username is \(username).", comment: "")
    }
    messageComposeViewController.body = body
    if MFMessageComposeViewController.canSendText() {
      presentViewController(messageComposeViewController, animated: true, completion: nil)
    }
  }
}

// MARK: -

extension FindFriendsViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }
}

// MARK: -

extension FindFriendsViewController: UITableViewDataSource {

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserTableViewCell),
      forIndexPath: indexPath)
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as! UserTableViewCell
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    cell.delegate = self
    let user = users[indexPath.row]
    cell.configureForObject(user)
  }
}

// MARK: -

extension FindFriendsViewController: UITableViewDelegate {

  // MARK: - UITableViewDelegate

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let user = users[indexPath.row]
    navigationController?.pushViewController(ProfileTimelineViewController(user: user), animated: true)
  }
}

// MARK: -

extension FindFriendsViewController: UserTableViewCellDelegate {

  // MARK: - UserTableViewCellDelegate

  func followUserButtonTappedInCell(cell: UserTableViewCell) {
    let indexPath = tableView.indexPathForCell(cell)!
    let user = users[indexPath.row]
    user.toggleFollowing()
    cell.configureForObject(user)
  }
}

// MARK: -

extension FindFriendsViewController: UITextFieldDelegate {

  // MARK: - UITextFieldDelegate

  func textFieldDidBeginEditing(textField: UITextField) {
    searching = true
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let text = textField.text where text.characters.count > 2 {
      searchForUserWithUsername(textField.text!)
    } else {
      cancelSearch()
    }
    return true
  }
}

// MARK: -

extension FindFriendsViewController: MFMessageComposeViewControllerDelegate {

  // MARK: - MFMessageComposeViewControllerDelegate

  func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
}