//
//  UIImageViewExtension.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

extension UIImageView {  
  public func setAsyncImage(url url: NSURL, placeholder: UIImage? = nil, options: Set<ResourceDownloadOptions> = []) {
    // Set background color
    self.backgroundColor = Flycatcher.sharedInstance.backgroundImageViewColor
    
    // Set the placeholder
    image = placeholder
    
    // Download asyncronally the image
    Flycatcher.imager.loadImage(url, into: self, options: options)
  }
  
  public func setAsyncImage(url url: String, placeholder: UIImage? = nil, options: Set<ResourceDownloadOptions> = []) {
    if let nsurl = NSURL(string: url) {
      setAsyncImage(url: nsurl, placeholder: placeholder, options: options)
    }
    else {
      debugPrint("Incorrect image URL")
    }
  }
}