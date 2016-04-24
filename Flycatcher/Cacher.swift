//
//  CachingManager.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

struct Cacher: FlycatcherRequestHandler {
  var request: FlycatcherRequest!
  
  mutating func handle(request: FlycatcherRequest) {
    self.request = request
    
    successor.handle(request)
  }
  
  func nextSuccessor() -> FlycatcherRequestHandler? {
    // The successor depends only on the presence of the data
    let result = self.request.partialResult
    
    switch result {
    case .Success(let resource):
      if resource.resourceData == nil && resource.resourceImage == nil {
        // It's an unknown resource, ask the loader it is in cache
        return CacheLoader()
      }
      else if resource.resourceImage == nil && resource.resourceData != nil {
        // I have some fresh new data, save it!
        return CacheSaver()
      }
      else {
        // I have image... no other chances! Returning completion
        return nil
      }
    case .Error:
      return nil
    }
  }
}

//MARK: - Saver

/**
 *  Cache saver - Saves the data to disk/memory (NSCache) and release the request
 *                as it came.
 */
struct CacheSaver: FlycatcherRequestHandler {
  mutating func handle(request: FlycatcherRequest) {
    
    switch request.partialResult {
    case .Error(_, _):
      self.successor.handle(request)
    case .Success(let resource):
      // Save data resource
      Cache.instance.addData(resource: resource)
      
      // Pass the image to GPU
      var decompressedImage: UIImage?
      let image = UIImage(data: resource.resourceData!)! //TODO: if it's not an image?
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        // Draw in another thread
        let context = UIGraphicsGetCurrentContext()!
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height))
        CGContextSetBlendMode(context, .Multiply)
        image.drawAtPoint(CGPointZero)
        decompressedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Save image resource
        Cache.instance.addImage(resource: resource, image: decompressedImage!)
        // Clear data
        Cache.instance.removeData(resource: resource)
        
        // Set image in main thread
        dispatch_async(dispatch_get_main_queue(), {
          var finalResource = resource
          finalResource.resourceImage = decompressedImage
          
          let finalResult = FlycatcherResult.Success(finalResource)
          
          var finalRequest = request
          finalRequest.partialResult = finalResult
          
          self.successor.handle(finalRequest)
        })
      })
    }
  }
  
  func nextSuccessor() -> FlycatcherRequestHandler? {
    return nil
  }
}

//MARK: - Loader

/**
 *  Cache loader - Load the data from disk/memory (NSCache)
 */
struct CacheLoader {
  let downloader = Downloader.instance
  var isCached = false

  lazy var libraryLocation: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)
    let libraryDirectory = urls.last
    
    return libraryDirectory!
  }()
  
  private func dataAt(url: NSURL, onDisk: Bool = true) -> NSData? {
    // Seach in memory
    if let data = Cache.instance.getData(url: url) {
      return data
    }
    
    //TODO: disk caching
    if onDisk {
      //let directoriesFilename = url.directoryTreeAndFileName
    }
    
    //FIXME: returning always nil
    return nil
  }
  
  private func imageAt(url: NSURL) -> UIImage? {
    // Seach in memory
    if let image = Cache.instance.getImage(url: url) {
      return image
    }
    
    //FIXME: returning always nil
    return nil
  }
}

extension CacheLoader: FlycatcherRequestHandler {
  mutating func handle(request: FlycatcherRequest) {
    var requestPartial = request
    var resource = request.partialResult.resource
    
    if let image = imageAt(resource.normalizedURL!) where request.cachingPolicy != .None {
      resource.resourceImage = image
      resource.isCached = true
      resource.immediateShow = true
    } else if let data = dataAt(resource.normalizedURL!, onDisk: request.cachingPolicy == .OnDisk) where request.cachingPolicy != .None {
      resource.resourceData = data
      resource.isCached = true
    }
    
    isCached = resource.isCached
    resource.isFromCache = true
    
    if (isCached) {
      requestPartial.partialResult = .Success(resource)
    }
    
    successor.handle(requestPartial)
  }
  
  func nextSuccessor() -> FlycatcherRequestHandler? {
    if isCached {
      return nil
    }
    else {
      return downloader
    }
  }
}