//
//  FlycatcherRequest.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 16/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

struct FlycatcherRequest {
  typealias downloadProgress = ((DownloadProgress) -> ())
  typealias completionBlock = ((FlycatcherResult) -> ())
  
  // Step result
  var partialResult: FlycatcherResult
 
  // Caching variables
  var cachingPolicy: CacheStoragePolicy = .Memory
  var cachingCondition: CacheConditionPolicy = .NoCondition

  // Options
  var cellularDataAllowed = true
  var downloadTimeout: Int16 = 25
  
  // Callbacks
  var progress: downloadProgress?
  var completion: completionBlock?
  
  init(partialResult: FlycatcherResult, progress: downloadProgress?, completion: completionBlock?) {
    self.partialResult = partialResult
    self.progress = progress
    self.completion = completion
  }
}
