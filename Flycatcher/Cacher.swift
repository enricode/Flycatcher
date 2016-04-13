//
//  CachingManager.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

struct Cacher: FlycatcherRequestHandler {
  let loader: CacheLoader!
  let saver: CacheSaver!
  
  init() {
    loader = CacheLoader()
    saver = CacheSaver()
  }
  
  func handle(resource: FlycatcherResource) {
    if let successor = successor(resource) {
      successor.handle(resource)
    }
  }
  
  func successor(resource: FlycatcherResource) -> FlycatcherRequestHandler? {
    if resource.resourceData != nil {
      return saver
    }
    else {
      return loader
    }
  }
}

struct CacheSaver: FlycatcherRequestHandler {
  func handle(resource: FlycatcherResource) {
    // Save fresh
    ResourcesCache.instance.add(resource: resource)
    
    if let successor = successor(resource) {
      successor.handle(resource)
    }
  }
  
  func successor(resource: FlycatcherResource) -> FlycatcherRequestHandler? {
    return Completor()
  }
}

struct CacheLoader: FlycatcherRequestHandler {
  let downloader = Downloader()
  lazy var libraryLocation: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)
    let libraryDirectory = urls.last
    
    return libraryDirectory!
  }()
  
  func handle(resource: FlycatcherResource) {
    var res = resource
    let urlToLoad = res.normalizedURL
    
    if let data = dataAt(urlToLoad!, onDisk: res.cachingPolicy == .OnDisk) where res.cachingPolicy != .None {
      res.resourceData = data
      res.isCached = true
    }
    
    if let successor = self.successor(resource) {
      res.isFromCache = true
      successor.handle(res)
    }
    else {
      if let completion = res.completion {
        completion(FlycatcherResult.Success(res))
      }
    }
  }
  
  func successor(resource: FlycatcherResource) -> FlycatcherRequestHandler? {
    if resource.resourceData != nil || resource.downloadedAt != nil {
      return Completor()
    }
    else {
      return downloader
    }
  }
  
  func dataAt(url: NSURL, onDisk: Bool = true) -> NSData? {
    // Seach in memory
    if let data = ResourcesCache.instance.get(url: url) {
      return data
    }
    
    if onDisk {
      let directoriesFilename = url.directoryTreeAndFileName
    }
    
    //FIXME: returning always nil
    return nil
  }
}