//
//  FlycatcherResource.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

struct FlycatcherResource {
  // URLs of resource
  let resourceURL: NSURL
  var normalizedURL: NSURL?
  
  // Creation date
  var downloadedAt: NSDate?
  
  // Cache
  var isFromCache = false
  var isCached = false
  var immediateShow = false

  // Concrete resource
  var resourceData: NSData?
  var resourceImage: UIImage?
 
  init(url: NSURL) {
    resourceURL = url
  }
}