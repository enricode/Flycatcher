//
//  LoadingViewController.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 14/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

let imagesToLoad = 15

class LoadingViewController: UIViewController, NSURLSessionDelegate {
  @IBOutlet weak var progressLabel: UILabel!
  
  var images = [NSURL]()
  var responses = 0
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    gatherImages()
  }
  
  func gatherImages() {
    let randomImage = NSURL(string: "https://source.unsplash.com/1600x900/?nature,water")!
    let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate: self, delegateQueue: nil)
    
    for _ in 0...imagesToLoad {
      let request = NSURLRequest(URL: randomImage, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 5)
      session.dataTaskWithRequest(request).resume()
    }
  }
  
  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    
  }
  
  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
    
    // Save image url
    if let responseURL = response.URL {
      images.append(responseURL)
    }
    
    responses += 1
    
    dispatch_async(dispatch_get_main_queue(), {
      self.progressLabel.text = "\(self.images.count + 1) / \(imagesToLoad)"
      
      if self.responses == imagesToLoad {
        let randomViewController = self.presentingViewController!.childViewControllers.first! as! RandomViewController
        self.dismissViewControllerAnimated(true, completion: {
          randomViewController.imageURLs = self.images
        })
        
        return
      }
    })
    
    completionHandler(.Cancel)
  }
}