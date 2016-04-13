//
//  ResourcesCache.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 13/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

class ResourcesCache {
  static let instance = ResourcesCache()
  private static var cache: NSCache!
  
  init() {
    resetCache()
  }
  
  func add(resource resource: FlycatcherResource) {
    guard let data = resource.resourceData, let url = resource.normalizedURL else {
      return
    }
    
    ResourcesCache.cache.setObject(data, forKey: url.absoluteString, cost: data.length)
  }
  
  func get(url url: NSURL) -> NSData? {
    let data = ResourcesCache.cache.objectForKey(url.normalizedURL) as? NSData
    
    return data
  }
  
  func resetCache() {
    ResourcesCache.cache = NSCache()
    ResourcesCache.cache.totalCostLimit = 20 * 1024 * 1024 * 8
  }
}