//
//  Completor.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 13/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

struct Completor: FlycatcherRequestHandler {
  func successor(resource: FlycatcherResource) -> FlycatcherRequestHandler? {
    return nil
  }
  
  func handle(resource: FlycatcherResource) {
    var result: FlycatcherResult!
    
    if resource.resourceData == nil {
      result = FlycatcherResult.Error(.InvalidURL)
    }
    
    if result == nil {
      result = FlycatcherResult.Success(resource)
    }
    
    if let completion = resource.completion {
      completion(result)
    }
  }
}