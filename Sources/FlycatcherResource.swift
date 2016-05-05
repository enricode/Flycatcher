//
//  FlycatcherResource.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

public struct FlycatcherResource {
  // URLs of resource
  public let resourceURL: NSURL
  public var normalizedURL: NSURL?
  
  // Creation date
  public var downloadedAt: NSDate?
  
  // Cache
  public var isFromCache = false
  public var isCached = false
  public var immediateShow = false

  // Concrete resource
  public var resourceData: NSData?
  public var resourceImage: UIImage?
 
  init(url: NSURL) {
    resourceURL = url
  }
}