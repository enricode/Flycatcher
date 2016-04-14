//
//  Flycatcher.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 09/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

protocol FlycatcherRequestHandler {
  mutating func handle(result: FlycatcherResult)
  func nextSuccessor() -> FlycatcherRequestHandler?
}

extension FlycatcherRequestHandler {
  var successor: FlycatcherRequestHandler {
    get {
      if let succ = self.nextSuccessor() {
        return succ
      }
      else {
        return Completor()
      }
    }
    set {
      
    }
  }
}

class Flycatcher {
  static var sharedInstance = Flycatcher()
  
  private lazy var downloadManager: DownloadManager = {
    return DownloadManager()
  }()
  
  class func manager() -> DownloadManager {
    return Flycatcher.sharedInstance.downloadManager
  }
  
  class func clearAllResourcesCache() {
    clearAllDiskCache()
    clearAllInMemoryCache()
  }
  
  class func clearAllDiskCache() {
    
  }
  
  class func clearAllInMemoryCache() {
    ResourcesCache.instance.resetCache()
  }
}