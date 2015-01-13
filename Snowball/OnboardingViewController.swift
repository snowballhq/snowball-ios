//
//  OnboardingViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class OnboardingViewController: UIViewController {
  let topImage = UIView()
  let signUpButton = UIButton()
  let signInButton = UIButton()
  let legalLabel = UILabel()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    topImage.backgroundColor = UIColor.SnowballColor.greenColor
    view.addSubview(topImage)
    layout(topImage) { (topImage) in
      topImage.left == topImage.superview!.left
      topImage.top == topImage.superview!.top
      topImage.right == topImage.superview!.right
      topImage.height == Float(UIScreen.mainScreen().bounds.size.height / 2)
    }

    let buttonMargin: Float = 25

    signUpButton.setTitle(NSLocalizedString("sign up"), forState: UIControlState.Normal)
    signUpButton.setTitleColor(UIColor.SnowballColor.greenColor, forState: UIControlState.Normal)
    signUpButton.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    signUpButton.alignLeft()
    signUpButton.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    signUpButton.addTarget(self, action: "signUpButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signUpButton)
    layout(signUpButton, topImage) { (signUpButton, topImage) in
      signUpButton.left == signUpButton.superview!.left + buttonMargin
      signUpButton.top == topImage.bottom + 40
      signUpButton.right == signUpButton.superview!.right - buttonMargin
      signUpButton.height == 50
    }

    signInButton.setTitle(NSLocalizedString("sign in"), forState: UIControlState.Normal)
    signInButton.setTitleColor(UIColor.SnowballColor.grayColor, forState: UIControlState.Normal)
    signInButton.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    signInButton.alignLeft()
    signInButton.addTarget(self, action: "signInButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signInButton)
    layout(signInButton, signUpButton) { (signInButton, signUpButton) -> () in
      signInButton.left == signUpButton.left
      signInButton.top == signUpButton.bottom + buttonMargin
      signInButton.right == signUpButton.right
      signInButton.height == signUpButton.height
    }

    legalLabel.text = NSLocalizedString("by continuing you are agreeing to the snowball terms of use and privacy policy")
    legalLabel.textColor = UIColor.SnowballColor.grayColor
    legalLabel.font = UIFont(name: UIFont.SnowballFont.bold, size: 10)
    legalLabel.numberOfLines = 0
    view.addSubview(legalLabel)
    layout(legalLabel) { (legalLabel) in
      let margin: Float = 45
      legalLabel.left == legalLabel.superview!.left + margin
      legalLabel.right == legalLabel.superview!.right - margin
      legalLabel.bottom == legalLabel.superview!.bottom - 30
    }
  }

  // MARK: - Actions

  func signUpButtonTapped() {
    println("sign up")
  }

  func signInButtonTapped() {
    println("sign in")
  }
}