//
//  UIImageViewExtensionTests.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Quick
import Nimble

class UIImageViewExtensionTests: QuickSpec {
  var imageView = UIImageView()
  
  override func spec() {
    describe("the UIImageView with extension") {
      
      beforeEach({
        self.imageView.setAsyncImage(url: "http://127.0.0.1:5123/dog.jpg")
      })
      
      context("with default settings") {
        it("has a light gray background view") {
          expect(self.imageView.backgroundColor).to(equal(Flycatcher.sharedInstance.backgroundImageViewColor))
        }
        
        context("loading image") {
          it("can set an asyncronous image") {
            self.imageView.setAsyncImage(url: "http://127.0.0.1:5123/dog.jpg")
            
            expect(self.imageView.image).toEventuallyNot(beNil(), timeout: 5)
          }
          
          it("shows an error label + retry when image is invalid or doesn't exist") {
            
          }
        }
      }
    }
  }
}