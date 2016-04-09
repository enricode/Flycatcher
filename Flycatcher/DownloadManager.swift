//
//  DownloadManager.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

class DownloadManager {
  var baseURL = NSURL()
  var concurrencyLevel: Int8 = 2
  
  func load(url: String,  completion: (FlycatcherResult) -> ()) {
    
  }
  
  func load(url: NSURL,  completion: (FlycatcherResult) -> ()) {
    
  }
  
  func load(url: String, options: Set<ResourceDownloadOptions>, progress: (NSProgress) -> (), completion: (FlycatcherResult) -> ()) {
    
  }
  
  func load(url: NSURL, options: Set<ResourceDownloadOptions>, progress: (NSProgress) -> (), completion: (FlycatcherResult) -> ()) {
    
  }
  
  func preload(urls: [NSURL]) {
    
  }
  
  func preload(urls: [String]) {
    
  }
  
  /*func load(urls: [String],  completion: (FlycatcherResult) -> ()) {
    
  }
  
  func load(urls: [String], options: Set<ResourceDownloadOptions>, progress: (NSProgress) -> (), completion: (FlycatcherResult) -> ()) {
    
  }
  
  func load(urls: [NSURL], options: Set<ResourceDownloadOptions>, progress: (NSProgress) -> (), completion: (FlycatcherResult) -> ()) {
    
  }*/
}