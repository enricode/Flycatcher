//
//  FlycatcherResult.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 09/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

public enum FlycatcherResult {
  case Error(FlycatcherResource, FlycatcherError)
  case Success(FlycatcherResource)
  
  public var resource: FlycatcherResource {
    switch self {
    case .Success(let resource):
      return resource
    case .Error(let resource, _):
      return resource
    }
  }
}