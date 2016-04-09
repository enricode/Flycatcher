//
//  DownloadManagerTests.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 07/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Quick
import Nimble

@testable import Flycatcher

let kBaseURL = "http://127.0.0.1:5123"

class DownloadManagerTests: QuickSpec {
  var manager: DownloadManager!
  
  private func getResource(result: FlycatcherResult, inout into res: FlycatcherResource?) {
    res = result.resource!
  }
  
  override func spec() {
    beforeEach { 
      self.manager = Flycatcher.manager()
    }
    
    describe("download manager") {
      
      beforeEach({
        Flycatcher.clearAllResourcesCache()
        Flycatcher.clearAllDiskCache()
        Flycatcher.clearAllInMemoryCache()
      })
      
      it("downloads a resource (image) asyncrounsly") {
        // Load with completion
        var dog1: UIImage?
        self.manager.load(kBaseURL + "/dog.jpg", completion: {result in
          if let dog = result.image {
            dog1 = dog
          }
        })
        
        // Load NSURL with completion
        var dog2: UIImage?
        self.manager.load(NSURL(string: kBaseURL + "/dog.jpg")!, completion: {result in
          if let dog = result.image {
            dog2 = dog
          }
        })
        
        // Load with option progress and completion
        var dog3: UIImage?
        self.manager.load(kBaseURL + "/dog.jpg", options: [], progress: { progress in }, completion: {result in
          if let dog = result.image {
            dog3 = dog
          }
        })
        
        // Preload a bunch of images
        /*self.manager.baseURL = NSURL(string: kBaseURL)
        let resources = self.manager.load(["bread.jpg", "koala.jpg"], options: [], progress { progress in }, completion: { result in
          //TODO: try to figure out how to put in result enum
        })*/
        
        expect(dog1).toEventuallyNot(beNil(), timeout: 3)
        expect(dog2).toEventuallyNot(beNil(), timeout: 3)
        expect(dog3).toEventuallyNot(beNil(), timeout: 3)
      }
      
      it("can download image if it's not cached") {
        
      }
      
      it("downloads resources in LIFO way") {
        // Resources
        let images = ["bread.jpg", "koala.jpg", "cat.png", "dog.jpg"]
        
        // Configuration
        self.manager.baseURL = NSURL(string: kBaseURL)!
        self.manager.concurrencyLevel = 1
        
        // Preload images
        self.manager.preload(images)
        
        // Get saved cached resources
        var bread, koala, cat, dog: FlycatcherResource?

        self.manager.load(kBaseURL + "/bread.jpg", completion:  { result in self.getResource(result, into: &bread) })
        self.manager.load(kBaseURL + "/koala.jpg", completion: { result in self.getResource(result, into: &koala) })
        self.manager.load(kBaseURL + "/cat.png", completion: { result in self.getResource(result, into: &cat) })
        self.manager.load(kBaseURL + "/dog.jpg", completion: { result in self.getResource(result, into: &dog) })
        
        // Wait for resources to be ready
        expect(dog).toEventuallyNot(beNil(), timeout: 3)
        
        // Check download time
        if dog != nil {
          expect(bread!.downloadedAt.doubleValue).to(beLessThanOrEqualTo(koala!.downloadedAt.doubleValue))
          expect(koala!.downloadedAt.doubleValue).to(beLessThanOrEqualTo(cat!.downloadedAt.doubleValue))
          expect(cat!.downloadedAt.doubleValue).to(beLessThanOrEqualTo(dog!.downloadedAt.doubleValue))
        }
      }
      
      it("doesn't download the same resource twice if caching is active (default)") {
        // Resourcs
        var breadDownloaded, breadCached: FlycatcherResource?
        
        // Load the same resource twice
        self.manager.load(kBaseURL + "/bread.jpg", completion: { result in breadDownloaded = result.resource! })
        self.manager.load(kBaseURL + "/bread.jpg", completion: { result in breadCached = result.resource! })
        
        // Waiting for resources to be ready
        expect(breadCached).toEventuallyNot(beNil(), timeout: 3)
        
        if breadCached != nil {
          expect(breadDownloaded!.isFromCache).to(beFalse())
          expect(breadCached!.isFromCache).to(beTrue())
          expect(breadDownloaded!.downloadedAt.doubleValue).to(equal(breadCached!.downloadedAt.doubleValue))
        }
      }
      
      context("with parallels downloads") {
        it("downloads multiple resources with concurrency") {
          
        }
      }
      
      context("custon FIFO way configuration") {
        it("downloads serially") {
          
        }
      }
    }
  }
}