//
//  FlycatcherRequest.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 16/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

public struct FlycatcherRequest {
  public typealias downloadProgress = ((DownloadProgress) -> ())
  public typealias completionBlock = ((FlycatcherResult) -> ())
  
  // Step result
  public  var partialResult: FlycatcherResult
 
  // Caching variables
  public var cachingPolicy: CacheStoragePolicy = .Memory
  public var cachingCondition: CacheConditionPolicy = .NoCondition

  // Options
  public var cellularDataAllowed = true
  public var downloadTimeout: Int16 = 25
  
  // Callbacks
  public var progress: downloadProgress?
  public var completion: completionBlock?
  
  init(partialResult: FlycatcherResult, progress: downloadProgress?, completion: completionBlock?) {
    self.partialResult = partialResult
    self.progress = progress
    self.completion = completion
  }
}
