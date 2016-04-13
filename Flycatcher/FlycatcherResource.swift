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
  let resourceURL: NSURL
  var normalizedURL: NSURL?
  
  // Creation date
  var downloadedAt: NSDate?
  
  // Caching variables
  var cachingPolicy: CacheStoragePolicy = .Memory
  var cachingCondition: CacheConditionPolicy = .NoCondition
  var isFromCache = false
  var isCached = false
  
  // Concrete resource
  var resourceData: NSData?
  
  // Options
  var cellularDataAllowed = true
  var downloadTimeout: Int16 = 25
  
  // Callbacks
  var progress: ((DownloadProgress) -> ())?
  var completion: ((FlycatcherResult) -> ())?
  
  init(url: NSURL) {
    resourceURL = url
    
    normalizedURL = nil
    downloadedAt = nil
    resourceData = nil
  }
}