//
//  Downloader.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 11/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

public class Downloader {
  static let instance = Downloader()
  
  let operationQueue: NSOperationQueue
  let maxOperaionInQueue = 20
  var successor: FlycatcherRequestHandler = Cacher()
  
  init() {
    operationQueue = NSOperationQueue()
    operationQueue.qualityOfService = .UserInteractive
  }

  /**
   * Callback for every download operation.
   */
  func operationComplete(operation: DownloadOperation) -> () -> () {
    return {
      // Get request and pass to successor
      var request = operation.request
      request.partialResult = operation.result
      
      self.successor.handle(request)
      
      // Pass all the similar download resources to next handler too
      for var acquainstance in operation.acquaintanceRequests {
        acquainstance.partialResult = operation.result
        
        self.successor.handle(acquainstance)
      }
    }
  }
}

extension Downloader: FlycatcherRequestHandler {
  func handle(request: FlycatcherRequest) {
    assert(request.partialResult.resource.resourceData == nil)
    
    // Update download manager
    operationQueue.maxConcurrentOperationCount = Flycatcher.downloader.concurrencyLevel
    
    // Check for pending operations and add to acquaintance
    for operation in operationQueue.operations {
      if operation is FlycatcherDownloadOperation {
        let downloadOperation = operation as! FlycatcherDownloadOperation
        
        // Check if resource is the same
        if downloadOperation.request.partialResult.resource.normalizedURL == request.partialResult.resource.normalizedURL {
          downloadOperation.touched = NSDate(timeIntervalSinceNow: 0)
          
          // Add to resource list only if there is a completion or a progress callback
          //if downloadOperation.resource.completion != nil || downloadOperation.resource.progress != nil {
            downloadOperation.acquaintanceRequests.append(request)
          //}
          
          return
        }
      }
    }
    
    // Create operation
    let operation = FlycatcherDownloadOperation(request: request)
    operation.completionBlock = operationComplete(operation)
    
    // Remove eventually some extra operation (the oldest one)
    // FIXME: minor bug: o -> ø -> o when cancelling a middle operation, the LIFO order should be preserved
    if operationQueue.operationCount == maxOperaionInQueue {
      let olderOperation = operationQueue.operations.minElement { ($0 as! FlycatcherDownloadOperation).touched.compare(($1 as! FlycatcherDownloadOperation).touched) == .OrderedAscending } as! FlycatcherDownloadOperation
      
      olderOperation.cancelLoad()
    }
    operationQueue.addOperationAtFrontOfQueue(operation)
  }
  
  func nextSuccessor() -> FlycatcherRequestHandler? {
    return Cacher()
  }
}