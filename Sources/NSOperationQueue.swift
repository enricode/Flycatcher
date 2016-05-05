//
//  NSOperation.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 13/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

extension NSOperationQueue {
  internal func setLIFODependendenciesForOperation(op: NSOperation) {
    // Suspend queue
    let wasSuspended: Bool = self.suspended
    self.suspended = true
    
    // Make op a dependency of all queued ops
    let maxOperations: Int = maxConcurrentOperationCount > 0 ? maxConcurrentOperationCount : Int.max
    
    var operations = self.operations
    let index: Int = operations.count - maxOperations
    if index >= 0 {
      let operation = operations[index]
      
      if !operation.executing {
        operation.addDependency(op)
      }
    }
    
    // Resume queue
    self.suspended = wasSuspended
  }

  internal func addOperationAtFrontOfQueue(op: NSOperation) {
    setLIFODependendenciesForOperation(op)
    addOperation(op)
  }
}