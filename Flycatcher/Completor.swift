//
//  Completor.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 13/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

struct Completor: FlycatcherRequestHandler {
  func nextSuccessor() -> FlycatcherRequestHandler? {
    return nil
  }
  
  func handle(result: FlycatcherResult) {
    if let completion = result.resource.completion {
      completion(result)
    }
  }
}