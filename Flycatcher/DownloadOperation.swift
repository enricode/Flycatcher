//
//  DownloadOperation.swift
//  Flycatcher
//
//  Created by Enrico Franzelli on 06/04/16.
//  Copyright © 2016 Capibara. All rights reserved.
//

import Foundation

// Manager will...
protocol DownloadOperationProtocol {
  func setupLoad()
  func cancelLoad()
}

// The custom download will tell the generic operation...
protocol DownloadOperationLifecycleProtocol {
  func loadReady()
  func loadStarted()
  func loadProgress(progress: DownloadProgress)
  func loadFinished()
  func loadCancelled()
}


class DownloadOperation: NSOperation, DownloadOperationLifecycleProtocol {
  var resource: FlycatcherResource!
  var result: FlycatcherResult!
  
  var expectedSize: Int = 0
  var currentSize: Int = 0
  
  enum State {
    case Ready, Executing, Finished, Cancelled
    
    func keyPath() -> String {
      switch self {
      case Ready:
        return "isReady"
      case Executing:
        return "isExecuting"
      case Finished:
        return "isFinished"
      case Cancelled:
        return "isCancelled"
      }
    }
  }
  
  var state = State.Ready {
    willSet {
      willChangeValueForKey(newValue.keyPath())
      willChangeValueForKey(state.keyPath())
    }
    didSet {
      didChangeValueForKey(oldValue.keyPath())
      didChangeValueForKey(state.keyPath())
    }
  }
  
  override var ready: Bool {
    return super.ready && state == .Ready
  }
  
  override var executing: Bool {
    return state == .Executing
  }
  
  override var finished: Bool {
    return state == .Finished
  }
  
  override var cancelled: Bool {
    return state == .Cancelled
  }
  
  override var asynchronous: Bool {
    return true
  }
  
  override init() {
    super.init()
  }
  
  init(resource: FlycatcherResource) {
    super.init()
    
    self.resource = resource
  }
  
  func loadProgress(progress: DownloadProgress) {
    if let progressClosure = resource.progress {
      progressClosure(progress)
    }
  }
  
  func loadReady() {
    state = .Ready
  }
  
  func loadStarted() {
    state = .Executing
  }
  
  func loadFinished() {
    state = .Finished
  }
  
  func loadCancelled() {
    state = .Cancelled
  }
}

class FlycatcherDownloadOperation: DownloadOperation, DownloadOperationProtocol {
  var sessionDataTask: NSURLSessionDataTask!
  var receivedData: NSMutableData?
  
  var resourceSize: DownloadProgress? {
    didSet {
      // Has finished?
      if resourceSize?.current == resourceSize?.total {
        resource.resourceData = receivedData
        
        // Tell the operation to conclude
        result = .Success(resource)
        
        loadFinished()
      }
      else {
        loadProgress(resourceSize!)
      }
    }
  }
  
  func setupLoad() {
    // Normalized resource url must be present
    guard let downloadURL = resource.normalizedURL else {
      debugPrint("Cannot download resource. The URL is nil")
      
      result = .Error(.InvalidURL)
      loadFinished()
      
      return
    }
    
    // Create session and request
    let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate: self, delegateQueue: nil)
    let request = NSMutableURLRequest(URL: downloadURL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: Double(resource.downloadTimeout))
    request.allowsCellularAccess = resource.cellularDataAllowed
    
    // Create session data task and start connecting
    sessionDataTask = session.dataTaskWithRequest(request)
    sessionDataTask.resume()
    
    // Tell the operation that loading is started
    self.loadReady()
  }
  
  override func main() {
    sessionDataTask.resume()
    self.loadStarted()
  }
  
  func cancelLoad() {
    // Cancel load
    sessionDataTask.cancel()
    
    // Tell the operation that loading is cancelled
    self.loadCancelled()
  }
}

extension FlycatcherDownloadOperation: NSURLSessionDelegate {
  @objc func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
    debugPrint("Download failed with error: \(error?.localizedFailureReason)")
  }
  
  @objc func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
    
  }
}

extension FlycatcherDownloadOperation: NSURLSessionDataDelegate {
  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    receivedData?.appendData(data)
    resourceSize = DownloadProgress(total: dataTask.countOfBytesReceived, current: dataTask.countOfBytesExpectedToReceive)
  }
  
  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
    // If the resource is already present, this means it's a new response
    receivedData = NSMutableData()
    resourceSize = DownloadProgress(total: response.expectedContentLength ?? NSURLSessionTransferSizeUnknown, current: 0)
    print("begin download \(resource.normalizedURL?.absoluteString)")
    completionHandler(NSURLSessionResponseDisposition.Allow)
  }
}