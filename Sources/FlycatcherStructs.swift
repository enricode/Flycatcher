//
//  FlycatcherStruct.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 11/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

public struct DownloadProgress {
  public let numberOfFiles = 1
  
  public let total: Int64
  public let current: Int64
  
  public var progress: Float {
    guard total != 0 else {
      return 0
    }
    
    return Float(self.total) / Float(self.current)
  }
}