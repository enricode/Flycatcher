//
//  Flycatcher.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 09/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

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
  
  private lazy var imageViewManager: FlycatcherImageViewManager = {
    return FlycatcherImageViewManager()
  }()
  
  var backgroundImageViewColor = UIColor(white: 230.0/255.0, alpha: 1)
  
  class func downloader() -> DownloadManager {
    return Flycatcher.sharedInstance.downloadManager
  }

  class func imager() -> FlycatcherImageViewManager {
    return Flycatcher.sharedInstance.imageViewManager
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