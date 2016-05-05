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
  
  func handle(request: FlycatcherRequest) {
    if let completion = request.completion {
      completion(request.partialResult)
    }
  }
}