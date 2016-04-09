//
//  FlycatcherResult.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 09/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

enum FlycatcherResult {
  case Error() //TODO: error kind
  case Success(FlycatcherResource)
  
  var image: UIImage? {
    switch self {
    case .Success(let resource):
      guard let imageData = resource.resourceData else {
        return nil
      }
      
      return UIImage(data: imageData)
    default:
      return nil
    }
  }
  
  var resource: FlycatcherResource? {
    switch self {
    case .Success(let resource):
      return resource
    default:
      return nil
    }
  }
}