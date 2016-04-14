//
//  CachingManager.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

struct Cacher: FlycatcherRequestHandler {
  var result: FlycatcherResult?
  
  mutating func handle(result: FlycatcherResult) {
    self.result = result
    
    successor.handle(result)
  }
  
  func nextSuccessor() -> FlycatcherRequestHandler? {
    guard let result = self.result else {
      return nil
    }
    
    switch result {
    case .Success(let resource):
      if resource.resourceData != nil {
        return CacheSaver()
      }
      else {
        return CacheLoader()
      }
    case .Error:
      return nil
    }
  }
}

struct CacheSaver: FlycatcherRequestHandler {
  mutating func handle(result: FlycatcherResult) {
    ResourcesCache.instance.add(resource: result.resource)
    
    successor.handle(result)
  }
  
  func nextSuccessor() -> FlycatcherRequestHandler? {
    return nil
  }
}

struct CacheLoader: FlycatcherRequestHandler {
  let downloader = Downloader.instance
  lazy var libraryLocation: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)
    let libraryDirectory = urls.last
    
    return libraryDirectory!
  }()
  
  mutating func handle(result: FlycatcherResult) {
    var resource = result.resource
    
    if let data = dataAt(resource.normalizedURL!, onDisk: resource.cachingPolicy == .OnDisk) where resource.cachingPolicy != .None {
      resource.resourceData = data
      resource.isCached = true
    }
    
    resource.isFromCache = true
    
    successor.handle(.Success(resource))
  }
  
  func nextSuccessor() -> FlycatcherRequestHandler? {
    return downloader
  }
  
  private func dataAt(url: NSURL, onDisk: Bool = true) -> NSData? {
    // Seach in memory
    if let data = ResourcesCache.instance.get(url: url) {
      return data
    }
    
    //TODO: disk caching
    if onDisk {
      //let directoriesFilename = url.directoryTreeAndFileName
    }
    
    //FIXME: returning always nil
    return nil
  }
}