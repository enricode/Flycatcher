//
//  FlycatcherEnums.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation


enum ResourceDownloadOptions {
  case PreciseURL
  
}

/**
 The CacheStoragePolicy enum defines constants that can be
 used to specify the type of storage that is allowable for a FlycatcherResource
 object that is to be stored.
 
 - Memory: Specifies that the resource will be stored in memory (default)
 - OnDisk: Specifies that the resource will be stored in memory and saved on disk
 - None:   Specifies that the resource will not be stored
 */
enum CacheStoragePolicy {
  case Memory
  case OnDisk
  case None
}

/**
 The CacheConditionPolicity enum defines constants that can be used to specify
 the condition that is used to choose when cache a resource.

 - NoCondition: No condition is apply, everything is cached (default)
 - MaxSize:     The condition is based on a maximum file size
 - MinSize:     The condition is based on a minimum file size
 */
enum CacheConditionPolicy {
  case NoCondition
  case MaxSize(Int32)
  case MinSize(Int32)
  //case Time(Int32)
}
