//
//  ResourcesCache.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 13/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

public enum CacheContainer: Int {
  case Data = 1
  case Image = 2
}

public class Cache {
  static var instance: Cache = {
    let cache = Cache()
    cache.resetCache()
    
    return cache
  }()
  private var caches: [CacheContainer: NSCache]!
  
  func addData(resource resource: FlycatcherResource) {
    if let data = resource.resourceData, let url = resource.normalizedURL {
      Cache.instance.caches[.Data]!.setObject(data.copy(), forKey: url.absoluteString, cost: data.length)
    }
  }
  
  func removeData(resource resource: FlycatcherResource) {
    if let url = resource.normalizedURL {
      Cache.instance.caches[.Data]!.removeObjectForKey(url.absoluteString)
    }
  }
  
  func addImage(resource resource: FlycatcherResource, image: UIImage) {
    if let url = resource.normalizedURL {
      Cache.instance.caches[.Image]!.setObject(image, forKey: url.absoluteString, cost: Int(image.size.height * image.size.width))
    }
  }
  
  func getData(url url: NSURL) -> NSData? {
    return Cache.instance.caches[.Data]!.objectForKey(url.absoluteString) as? NSData
  }
  
  func getImage(url url: NSURL) -> UIImage? {
    return Cache.instance.caches[.Image]!.objectForKey(url.absoluteString) as? UIImage
  }
  
  func resetCache() {
    self.caches = [
      CacheContainer.Data: NSCache(),
      CacheContainer.Image: NSCache()
    ]
    self.caches.keys.forEach { key in
       self.caches[key]!.totalCostLimit = 80 * 1024 * 1024 * 8 * 2
    }
  }
}