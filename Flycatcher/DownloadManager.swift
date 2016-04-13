//
//  DownloadManager.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

protocol FlycatcherRequestHandler {
  func handle(resource: FlycatcherResource)
  func successor(resource: FlycatcherResource) -> FlycatcherRequestHandler?
}

protocol FlycatcherDownloadManager {
  var baseURL: NSURL { get set }
  var concurrencyLevel: Int { get set }
  
  func load(url: NSURL, options: Set<ResourceDownloadOptions>, progress: ((DownloadProgress) -> Void)?, completion: ((FlycatcherResult) -> Void)?)
  func preload(urls: [String])
}

class DownloadManager: FlycatcherDownloadManager {  
  let defaultResourceDownloadOptions: Set<ResourceDownloadOptions> = []
  lazy var cachingManager: Cacher = {
    Cacher()
  }()
  
  /// The base URL to use when loading resource
  var baseURL = NSURL()
  
  /// Specify how many download are simultaneously executing while
  /// downloading resources.
  var concurrencyLevel: Int = 2 {
    didSet(newValue) {
      if newValue > 8 {
        print("Concurrency level cannot be great than 8. Setting it to 8.")
        concurrencyLevel = 8
      }
      
      if newValue < 1 {
        print("Concurrency level cannot be lower than 1. Setting it to 1.")
        concurrencyLevel = 1
      }
    }
  }
  
  func load(url: String, completion: ((FlycatcherResult) -> Void)?) {
    let nsurl = NSURL(string: url)
    
    if let correctURL = nsurl {
      self.load(correctURL, completion: completion)
    }
    else {
      print("The URL \(url) was malformed, cannot load it")
    }
  }
  
  func load(url: NSURL, completion: ((FlycatcherResult) -> Void)?) {
    self.load(url, options: defaultResourceDownloadOptions, progress: nil, completion: completion)
  }
  
  func load(url: String, options: Set<ResourceDownloadOptions> = [], progress: ((DownloadProgress) -> ())?, completion: ((FlycatcherResult) -> ())?) {
    let nsurl = NSURL(string: url)
    
    if let correctURL = nsurl {
      self.load(correctURL, options: options, progress: progress, completion: completion)
    }
    else {
      print("The URL \(url) was malformed, cannot load it")
    }
  }
  
  func load(url: NSURL, options: Set<ResourceDownloadOptions>, progress: ((DownloadProgress) -> ())?, completion: ((FlycatcherResult) -> Void)?) {
    // Construct resource
    var resource = FlycatcherResource(url: url)
    
    // Disable URL normalize
    if options.contains(.PreciseURL) {
      resource.normalizedURL = url
    }
    else {
      resource.normalizedURL = url.normalizedURL
    }
    
    // Disable cell data if needed
    if options.contains(.DisableCellularData) {
      resource.cellularDataAllowed = false
    }
    
    // Download timeout
    if options.contains(.DownloadTimeout(0)) {
      let timeoutSet: Set<ResourceDownloadOptions> = [.DownloadTimeout(0)]
      let timeout = options.intersect(timeoutSet).first!
      
      switch timeout {
      case .DownloadTimeout(let timeout):
        resource.downloadTimeout = timeout
      default: break
      }
    }
    
    // Closures
    if progress != nil {
      resource.progress = progress
    }
    if completion != nil {
      resource.completion = completion
    }
    
    // Pass to successor
    successor(resource)!.handle(resource)
  }
  
  func preload(urls: [NSURL]) {
    urls.forEach { (url) in
      load(url, completion: nil)
    }
  }
  
  func preload(urls: [String]) {
    let nsUrls = urls.flatMap { (stringURL) -> NSURL? in
      if let url = NSURL(string: stringURL) {
        return url
      }
      return nil
    }
    
    preload(nsUrls)
  }
}

extension DownloadManager: FlycatcherRequestHandler {
  func successor(resource: FlycatcherResource) -> FlycatcherRequestHandler? {
    return cachingManager
  }
  
  func handle(resource: FlycatcherResource) {
    
  }
}