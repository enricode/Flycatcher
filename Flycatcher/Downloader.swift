//
//  Downloader.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 11/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

struct Downloader {
  let operationQueue: NSOperationQueue
  
  init() {
    operationQueue = NSOperationQueue()
    operationQueue.qualityOfService = .UserInteractive
  }
}

extension Downloader: FlycatcherRequestHandler {
  func handle(resource: FlycatcherResource) {
    // Update download manager
    operationQueue.maxConcurrentOperationCount = Flycatcher.manager().concurrencyLevel
    
    let operation = FlycatcherDownloadOperation(resource: resource)
    operation.setupLoad()
    operation.completionBlock = operationComplete(operation)
    
    operationQueue.addOperationAtFrontOfQueue(operation)    
  }
  
  func operationComplete(operation: DownloadOperation) -> () -> () {
    return {
      let result = operation.result
      
      // Fill attributes
      var res = result.resource!
      res.downloadedAt = NSDate(timeIntervalSinceNow: 0)
      
      self.successor(res)?.handle(res)
    }
  }
  
  func successor(resource: FlycatcherResource) -> FlycatcherRequestHandler? {
    return Cacher()
  }
}

/*
extension Downloader: DownloaderDelegate {
  func operation(operation: DownloadOperation, completedWithResult: FlycatcherResult) {
    
  }
  
  func operation(operation: DownloadOperation, progress: DownloadProgress) {
    
  }
}*/