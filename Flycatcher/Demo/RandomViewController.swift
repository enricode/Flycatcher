//
//  ViewController.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 14/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import UIKit

class RandomViewController: UITableViewController, NSURLSessionDataDelegate {
  
  var imageURLs = [NSURL]() {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Tweet")! as UITableViewCell
    
    let imageView = cell.viewWithTag(1) as! UIImageView
    let image = imageURLs[indexPath.row]
    imageView.setAsyncImage(url: image, placeholder: nil, options: [.RemoveFadeIn])
    
    return cell
  }
 
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return imageURLs.count
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}