//
//  FlycatcherStruct.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 11/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

struct DownloadProgress {
  let numberOfFiles = 1
  
  let total: Int64
  let current: Int64
  
  var progress: Float {
    guard total != 0 else {
      return 0
    }
    
    return Float(self.total) / Float(self.current)
  }
}