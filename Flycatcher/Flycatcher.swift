//
//  Flycatcher.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 09/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

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