//
//  FlycatcherEnums.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

/**
 The ResourceDownloadOptions enum defines constats to group that can be
 used to specity the options for downloading a FlycatcherResource.
 
 - PreciseURL:          Disable the normalizing of URL (ex: GET query URL isn't ignored)
 - DisableCellularData: Disable the use of cellular data. This should be implemented on custom download operation.
 - DownloadTimeout:     Timeout for requesting the data (default is 5 seconds)
 - DownloadTimeoutData: Timeout for downloading the data (default is 25 seconds)
 */
enum ResourceDownloadOptions {
  case PreciseURL
  case DisableCellularData
  case DownloadTimeout(Int16)
}

extension ResourceDownloadOptions: Hashable {
  var hashValue: Int {
    switch self {
    case .PreciseURL:
      return 1
    case .DisableCellularData:
      return 2
    case .DownloadTimeout(_):
      return 3
    }
  }
}

// Equatable
func ==(lhs: ResourceDownloadOptions, rhs: ResourceDownloadOptions) -> Bool {
  return lhs.hashValue == rhs.hashValue
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


enum FlycatcherError {
  case InvalidURL
}