//
//  FlycatcherResource.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

struct FlycatcherResource {
  // URLs of resource
  let resourceURL: String
  let sanitizedResourceURL: NSURL
  
  // Creation date
  let downloadedAt: NSDate
  
  // Caching variables
  let cachingPolicy: CacheStoragePolicy
  let cachingCondition: CacheConditionPolicy
  var isFromCache = false
  var isCached = false
  
  // Concrete resouce
  let resourceData: NSData?
}