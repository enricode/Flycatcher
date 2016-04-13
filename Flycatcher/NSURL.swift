//
//  NSURL.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 13/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

extension NSURL {
    /// Return an URL normalized according to RFC3986
  var normalizedURL: NSURL {
    //TODO: follow all the rules
    //https://en.wikipedia.org/wiki/URL_normalization#Normalizations_that_preserve_semantics
    guard let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: true) else {
      debugPrint("Can't normalize URL \(self.absoluteString). Returning the same URL.")
      
      return self
    }
    
    // Removing port 80
    if let port = components.port?.integerValue where port == 80 {
      components.port = nil
    }
    
    // Lowercasing host and scheme
    components.host = components.host?.lowercaseString
    components.scheme = components.scheme?.lowercaseString
    
    if let normalized = components.URL {
      return normalized
    }
    
    debugPrint("Can't normalize URL \(self.absoluteString). Returning the same URL.")
    
    return self
  }
  
  func directoryTreeAndFileName() -> (diretoryTree: [String], filename: String)? {
    let components = self.pathComponents
    
    // Get directory tree
    let dirs = components?.flatMap({ (component) -> String? in
      if component == "" || component == "/" {
        return nil
      }
      return component
    })
    
    guard var directories = dirs where directories.count > 0 else {
      return nil
    }
    
    // Get filename
    var filename = directories.removeLast()
    // -> appending query
    if let query = self.query {
      filename += query
    }
    
    // Website name
    if let host = self.host?.lowercaseString {
      directories.insert(host, atIndex: 0)
    }
    else {
      return nil
    }
    
    return (directories, filename)
  }
}