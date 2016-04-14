//
//  Downloader.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 11/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

class Downloader {
  static let instance = Downloader()
  
  let operationQueue: NSOperationQueue
  let maxOperaionInQueue = 20
  var successor: FlycatcherRequestHandler = Cacher()
  
  init() {
    operationQueue = NSOperationQueue()
    operationQueue.qualityOfService = .UserInteractive
  }
}

extension Downloader: FlycatcherRequestHandler {
  func handle(result: FlycatcherResult) {
    // Update download manager
    operationQueue.maxConcurrentOperationCount = Flycatcher.downloader().concurrencyLevel
    
    // Check if the download is needed
    guard result.resource.resourceData == nil else {
      successor.handle(result)
      
      return
    }
    
    // Check for pending operations and add to acquaintance
    for operation in operationQueue.operations {
      if operation is FlycatcherDownloadOperation {
        let downloadOperation = operation as! FlycatcherDownloadOperation
        
        // Check if resource is the same
        if downloadOperation.resource.normalizedURL == result.resource.normalizedURL {
          downloadOperation.touched = NSDate(timeIntervalSinceNow: 0)
          
          // Add to resource list only if there is a completion or a progress callback
          //if downloadOperation.resource.completion != nil || downloadOperation.resource.progress != nil {
            downloadOperation.acquaintanceResources.append(result.resource)
          //}
          
          return
        }
      }
    }
    
    // Create operation
    let operation = FlycatcherDownloadOperation(resource: result.resource)
    operation.setupLoad()
    operation.completionBlock = operationComplete(operation)
    
    // Remove eventually some extra operation (the oldest one)
    // FIXME: minor bug - o -> ø -> o when cancelling a middle operation, the LIFO order should be preserved 
    if operationQueue.operationCount == maxOperaionInQueue {
      let olderOperation = operationQueue.operations.minElement { ($0 as! FlycatcherDownloadOperation).touched.compare(($1 as! FlycatcherDownloadOperation).touched) == .OrderedAscending } as! FlycatcherDownloadOperation
      
      olderOperation.cancelLoad()
    }
    
    operationQueue.addOperationAtFrontOfQueue(operation)    
  }
  
  func operationComplete(operation: DownloadOperation) -> () -> () {
    return {
      var downloadedResource = operation.result.resource
      downloadedResource.downloadedAt = NSDate(timeIntervalSinceNow: 0)
      
      //TODO: refactor me
      switch operation.result as FlycatcherResult {
      case .Error(_, let error):
        self.successor.handle(.Error(downloadedResource, error))
      default:
        self.successor.handle(.Success(downloadedResource))
      }
      
      // Pass all the similar download resources to next handler too
      for resource in operation.acquaintanceResources {
        var copyResource = resource
        copyResource.downloadedAt = downloadedResource.downloadedAt
        copyResource.resourceData = downloadedResource.resourceData
        
        switch operation.result as FlycatcherResult {
        case .Error(_, let error):
          self.successor.handle(.Error(copyResource, error))
        default:
          self.successor.handle(.Success(copyResource))
        }
      }
      //end TODO
    }
  }
  
  func nextSuccessor() -> FlycatcherRequestHandler? {
    return Cacher()
  }
}