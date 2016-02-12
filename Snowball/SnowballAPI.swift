//
//  SnowballAPI.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation
import RealmSwift

struct SnowballAPI {

  // MARK: Internal

  static func requestObjects<T: Object>(route: SnowballRoute, completion: (response: ObjectResponse<[T]>) -> Void) {
    requestObjects(route, eachObjectBeforeSave: nil, completion: completion)
  }

  static func requestObjects<T: Object>(route: SnowballRoute, eachObjectBeforeSave: ((object: T) -> Void)?, completion: (response: ObjectResponse<[T]>) -> Void) {
    Alamofire.request(route).responseJSON { afResponse in
      switch afResponse.result {
      case .Success(let value):
        if let value = value as? JSONArray {
          var objects = [T]()
          Database.performTransaction {
            objects = T.fromJSONArray(value)
            for object in objects {
              eachObjectBeforeSave?(object: object)
              Database.save(object)
            }
          }
          completion(response: .Success(objects))
        } else {
          completion(response: .Failure(NSError.snowballErrorWithReason(nil)))
        }
      case .Failure(let error):
        completion(response: .Failure(error))
      }
    }
  }

  static func queueClipForUploadingAndHandleStateChanges(clip: Clip, completion: (response: ObjectResponse<Clip>) -> Void) {
    guard let videoURLString = clip.videoURL, videoURL = NSURL(string: videoURLString) else { return }
    guard let thumbnailURLString = clip.thumbnailURL, thumbnailURL = NSURL(string: thumbnailURLString) else { return }

    Database.performTransaction {
      clip.state = .Uploading
      Database.save(clip)
    }

    let onFailure = {
      Database.performTransaction {
        clip.state = .UploadFailed
        Database.save(clip)
      }
      completion(response: .Failure(NSError.snowballErrorWithReason("Clip upload failed.")))
    }

    ClipUploadQueue.addOperationWithBlock {
      let multipartFormData: (MultipartFormData -> Void) = { multipartFormData in
        multipartFormData.appendBodyPart(fileURL: videoURL, name: "video")
        multipartFormData.appendBodyPart(fileURL: thumbnailURL, name: "thumbnail")
      }
      Alamofire.upload(SnowballRoute.UploadClip, multipartFormData: multipartFormData) { encodingResult in
        switch(encodingResult) {
        case .Success(let upload, _, _):
          upload.responseJSON { response in
            switch(response.result) {
            case .Success(let value):
              if let JSON = value as? JSONObject {
                Database.performTransaction {
                  let parsedClip: Clip = Clip.fromJSONObject(JSON)
                  parsedClip.state = .Default
                  Database.save(parsedClip)
                }
              } else { onFailure() }
            case .Failure: onFailure()
            }
          }
        case .Failure: onFailure()
        }
      }
    }
  }

  // MARK: Private

  // This is unused but should probably be used in some form (maybe refactored first?)

//  private static func responseError(response: Alamofire.Response<AnyObject, NSError>) -> NSError {
//    var error = NSError.snowballErrorWithReason(nil)
//    if let data = response.data {
//      do {
//        if let serverErrorJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject], let message = serverErrorJSON["message"] as? String {
//          error = NSError.snowballErrorWithReason(message)
//          return error
//        }
//      } catch {}
//    }
//    return error
//  }
}

// MARK: - ObjectResponse
enum ObjectResponse<T> {
  case Success(T)
  case Failure(NSError)
}