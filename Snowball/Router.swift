//
//  Router.swift
//  Snowball
//
//  Created by James Martinez on 12/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

enum Router: URLRequestConvertible {
  // Authentication
  case SignUp(username: String, email: String, password: String)
  case SignIn(email: String, password: String)
  // User
  case GetCurrentUser
  case UpdateCurrentUser(name: String?, username: String?, email: String?, phoneNumber: String?)
  case GetCurrentUserFollowers
  case GetCurrentUserFollowing
  case FollowUser(userID: String)
  case UnfollowUser(userID: String)
  case FindUsersByPhoneNumbers(phoneNumbers: [String])
  case FindUsersByUsername(username: String)
  // Clip
  case GetClipStream
  case GetClipStreamForUser(userID: String)
  case DeleteClip(clipID: String)
  case FlagClip(clipID: String)

  // MARK: - Properties

  static let baseURLString: String = {
    if isStaging() {
      return "https://api-staging.snowball.is/v1"
    }
    return "https://api.snowball.is/v1/"
    }()

  private var method: Alamofire.Method {
    switch self {
    case .SignUp: return .POST
    case .SignIn: return .POST
    case .GetCurrentUser: return .GET
    case .UpdateCurrentUser: return .PATCH
    case .GetCurrentUserFollowers: return .GET
    case .GetCurrentUserFollowing: return .GET
    case .FollowUser: return .POST
    case .UnfollowUser: return .DELETE
    case .FindUsersByPhoneNumbers: return .POST
    case .FindUsersByUsername: return .GET
    case .GetClipStream: return .GET
    case .GetClipStreamForUser: return .GET
    case .DeleteClip: return .DELETE
    case .FlagClip: return .POST
    }
  }

  private var path: String {
    switch self {
    case .SignUp: return "users/sign-up"
    case .SignIn: return "users/sign-in"
    case .GetCurrentUser: return "users/me"
    case .UpdateCurrentUser: return "users/me"
    case .GetCurrentUserFollowers: return "users/me/followers"
    case .GetCurrentUserFollowing: return "users/me/following"
    case .FollowUser(let userID): return "users/\(userID)/follow"
    case .UnfollowUser(let userID): return "users/\(userID)/follow"
    case .FindUsersByPhoneNumbers: return "users/phone-search"
    case .FindUsersByUsername: return "users"
    case .GetClipStream: return "clips/stream"
    case .GetClipStreamForUser(let userID): return "users/\(userID)/clips/stream"
    case .DeleteClip(let clipID): return "clips/\(clipID)"
    case .FlagClip(let clipID): return "clips/\(clipID)/flags"
    }
  }

  private var parameterEncoding: ParameterEncoding? {
    switch self {
    case .SignUp: return ParameterEncoding.JSON
    case .SignIn: return ParameterEncoding.JSON
    case .UpdateCurrentUser: return ParameterEncoding.JSON
    case .FindUsersByPhoneNumbers: return ParameterEncoding.JSON
    case .FindUsersByUsername: return ParameterEncoding.URL
    default: return nil
    }
  }

  private var parameters: [String: AnyObject]? {
    switch self {
    case .SignUp(let username, let email, let password): return ["username": username, "email": email, "password": password]
    case .SignIn(let email, let password): return ["email": email, "password": password]
    case .UpdateCurrentUser(let name, let username, let email, let phoneNumber):
      var userParameters = [String: String]()
      if let newUsername = username {
        userParameters["username"] = newUsername
      }
      if let newEmail = email {
        userParameters["email"] = newEmail
      }
      if let newName = name {
        userParameters["name"] = newName
      }
      if let newPhoneNumber = phoneNumber {
        userParameters["phone_number"] = newPhoneNumber
      }
      return userParameters
    case .FindUsersByPhoneNumbers(let phoneNumbers): return ["phone_numbers": phoneNumbers]
    case .FindUsersByUsername(let username): return ["username": username]
    default: return nil
    }
  }

  // MARK: - URLRequestConvertible

  var URLRequest: NSURLRequest {
    let URL = NSURL(string: Router.baseURLString)
    let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
    mutableURLRequest.HTTPMethod = method.rawValue
    if let authToken = APICredential.authToken {
      let encodedAuthTokenData = "\(authToken):".dataUsingEncoding(NSUTF8StringEncoding)!
      let encodedAuthToken = encodedAuthTokenData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      mutableURLRequest.setValue("Basic \(encodedAuthToken)", forHTTPHeaderField: "Authorization")
    }
    if let params = parameters {
      return parameterEncoding!.encode(mutableURLRequest, parameters: params).0
    }
    return mutableURLRequest
  }
}

struct APICredential {
  private static let kCurrentUserAuthTokenKey = "CurrentUserAuthToken"
  static var authToken: String? {
    get {
      return NSUserDefaults.standardUserDefaults().objectForKey(kCurrentUserAuthTokenKey) as! String?
    }
    set {
      if let authToken = newValue {
        NSUserDefaults.standardUserDefaults().setObject(authToken, forKey: kCurrentUserAuthTokenKey)
      } else {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kCurrentUserAuthTokenKey)
      }
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }
}