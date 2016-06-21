//
//  Flycatcher.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 09/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

public class Flycatcher {
  static var sharedInstance = Flycatcher()
  
  private lazy var downloadManager: DownloadManager = {
    return DownloadManager()
  }()
  
  private lazy var imageViewManager: FlycatcherImageViewManager = {
    return FlycatcherImageViewManager()
  }()
  
  var backgroundImageViewColor = UIColor(white: 230.0/255.0, alpha: 1)
  
  public static var downloader: DownloadManager {
    return Flycatcher.sharedInstance.downloadManager
  }

  public static var imager: FlycatcherImageViewManager {
    return Flycatcher.sharedInstance.imageViewManager
  }
  
  public class func clearAllResourcesCache() {
    clearAllDiskCache()
    clearAllInMemoryCache()
  }
  
  public class func clearAllDiskCache() {
    
  }
  
  public class func clearAllInMemoryCache() {
    Cache.instance.resetCache()
  }
}

/**
 *  Chain of responsibility
 */
protocol FlycatcherRequestHandler {
  mutating func handle(request: FlycatcherRequest)
  func nextSuccessor() -> FlycatcherRequestHandler?
}

// If there's no successor, go to completor
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