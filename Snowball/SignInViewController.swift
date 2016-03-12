//
//  SignInViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

class SignInViewController: UIViewController {

  // MARK: Properties

  let topLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.text = NSLocalizedString("Welcome back!\nLogin to your account.", comment: "")
    label.font = UIFont.SnowballFont.regularFont.fontWithSize(20)
    return label
  }()

  let emailTextFieldContainer: TextFieldContainerView = {
    let textFieldContainer = TextFieldContainerView()
    textFieldContainer.configureText(hint: NSLocalizedString("Email", comment: ""), placeholder: NSLocalizedString("Your email address", comment: ""))
    textFieldContainer.textField.autocapitalizationType = .None
    textFieldContainer.textField.autocorrectionType = .No
    textFieldContainer.textField.spellCheckingType = .No
    textFieldContainer.textField.keyboardType = .EmailAddress
    textFieldContainer.textField.returnKeyType = .Next
    return textFieldContainer
  }()

  let passwordTextFieldContainer: TextFieldContainerView = {
    let textFieldContainer = TextFieldContainerView()
    textFieldContainer.configureText(hint: NSLocalizedString("Password", comment: ""), placeholder: NSLocalizedString("Your password", comment: ""))
    textFieldContainer.textField.autocapitalizationType = .None
    textFieldContainer.textField.autocorrectionType = .No
    textFieldContainer.textField.spellCheckingType = .No
    textFieldContainer.textField.returnKeyType = .Go
    textFieldContainer.textField.secureTextEntry = true
    return textFieldContainer
  }()

  let submitButton: SnowballActionButton = {
    let button = SnowballActionButton()
    button.setTitle(NSLocalizedString("log in", comment: ""), forState: .Normal)
    return button
  }()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topLabel)
    constrain(topLabel) { topLabel in
      topLabel.left == topLabel.superview!.left + TextFieldContainerView.defaultSideMargin
      topLabel.top == topLabel.superview!.top + 50
      topLabel.width == topLabel.superview!.width * 0.70
    }

    view.addSubview(emailTextFieldContainer)
    constrain(emailTextFieldContainer, topLabel) { emailTextFieldContainer, topLabel in
      emailTextFieldContainer.left == emailTextFieldContainer.superview!.left + TextFieldContainerView.defaultSideMargin
      emailTextFieldContainer.top == topLabel.bottom + 40
      emailTextFieldContainer.right == emailTextFieldContainer.superview!.right - TextFieldContainerView.defaultSideMargin
      emailTextFieldContainer.height == TextFieldContainerView.defaultHeight
    }
    emailTextFieldContainer.textField.delegate = self

    view.addSubview(passwordTextFieldContainer)
    constrain(passwordTextFieldContainer, emailTextFieldContainer) { passwordTextFieldContainer, emailTextFieldContainer in
      passwordTextFieldContainer.left == emailTextFieldContainer.left
      passwordTextFieldContainer.top == emailTextFieldContainer.bottom + TextFieldContainerView.defaultSpaceBetween
      passwordTextFieldContainer.right == emailTextFieldContainer.right
      passwordTextFieldContainer.height == emailTextFieldContainer.height
    }
    passwordTextFieldContainer.textField.delegate = self
    passwordTextFieldContainer.linkSizingWithTextFieldContainerView(emailTextFieldContainer)

    view.addSubview(submitButton)
    constrain(submitButton, passwordTextFieldContainer) { submitButton, passwordTextFieldContainer in
      submitButton.left == passwordTextFieldContainer.left
      submitButton.top == passwordTextFieldContainer.bottom + 40
      submitButton.right == passwordTextFieldContainer.right
      submitButton.height == SnowballActionButton.defaultHeight
    }
    submitButton.addTarget(self, action: "submitButtonPressed", forControlEvents: .TouchUpInside)
  }

  // MARK: Actions

  @objc private func submitButtonPressed() {
    signIn()
  }

  // MARK: Private

  private func signIn() {
    guard let email = emailTextFieldContainer.textField.text, let password = passwordTextFieldContainer.textField.text else { return }
    SnowballAPI.requestObject(SnowballRoute.SignIn(email: email, password: password)) { (response: ObjectResponse<User>) in
      switch response {
      case .Success(let user):
        User.currentUser = user
        // TODO: Analytics
        // TODO: Push notifications
        self.dismissViewControllerAnimated(true, completion: nil)
      case .Failure(let error): print(error)
      }
    }
  }
}

extension SignInViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == emailTextFieldContainer.textField {
      passwordTextFieldContainer.textField.becomeFirstResponder()
    } else if textField == passwordTextFieldContainer.textField {
      signIn()
    }
    return true
  }
}