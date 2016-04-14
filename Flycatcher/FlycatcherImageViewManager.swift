//
//  FlycatcherImageViewManager.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 14/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

struct FlycatcherImageViewManager {
  static var registry = ImageViewRegistry()
  
  func loadImage(url: NSURL, into imageView: UIImageView, options: Set<ResourceDownloadOptions>) {
    // Register the couple of image view and url associated
    FlycatcherImageViewManager.registry.add(ImageViewRegistry.Couple(imageView: imageView, url: url.absoluteString))
    
    Flycatcher.downloader().load(url, options: options, progress: nil) { [weak weakImageView = imageView] (result) in
      // Check for image resource
      guard let image = result.image, let imageView = weakImageView else {
        return
      }
      
      // Check if imageView is still associated with url
      guard FlycatcherImageViewManager.registry.stillValid(ImageViewRegistry.Couple(imageView: imageView, url: url.absoluteString)) else {
        return
      }
      
      var decompressedImage: UIImage?
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
        
        // Set image in main thread
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
          guard FlycatcherImageViewManager.registry.stillValid(ImageViewRegistry.Couple(imageView: imageView, url: url.absoluteString)) else {
            return
          }
          
          // Crossfade transition
          if (options.contains(.RemoveFadeIn)) {
            weakImageView?.image = decompressedImage
          }
          else {
            UIView.transitionWithView(weakImageView!,
              duration: 0.25,
              options: UIViewAnimationOptions.TransitionCrossDissolve,
              animations: { weakImageView?.image = decompressedImage },
              completion: nil)
          }
          
          FlycatcherImageViewManager.registry.remove(imageView)
        })
      })
    }
  }
}

struct ImageViewRegistry {
  struct Couple {
    let imageView: UIImageView
    let url: String
  }
  
  var registry: [Couple] = []
  
  /**
   Returns a Boolean indicating if the imageView is still valid with the
   couple of url and reference to imageView passed.
   
   - parameter imUrl: The couple that the system thinks could be the correct one
   */
  func stillValid(imUrl: Couple) -> Bool {
    return self.registry.contains { (couple) -> Bool in
      couple == imUrl
    }
  }
  
  /**
   Adds a couple of imageView/url in the registry. The couple added is what
   the developer wants to display in the UIImageView.
   
   - parameter imUrl: The couple that the developer wants to display
   */
  mutating func add(imUrl: Couple) {
    // Search for the same value
    if (self.registry.contains { $0 == imUrl }) {
      // ignore
      return
    }

    // The same imageView is used by another url?
    if let indexToRemove = (self.registry.indexOf { $0.imageView === imUrl.imageView } ) {
      self.registry.removeAtIndex(indexToRemove)
    }
    
    // Add the couple
    self.registry.append(imUrl)
  }
  
  /**
   Removes the entry.
   
   - parameter imUrl: Entry to be removed from registry
   */
  mutating func remove(imageView: UIImageView) {
    if let index = (self.registry.indexOf { $0.imageView === imageView }) {
      self.registry.removeAtIndex(index)
    }
  }
}

func ==(l: ImageViewRegistry.Couple, r: ImageViewRegistry.Couple) -> Bool {
  return (l.imageView === r.imageView) && (l.url == r.url)
}