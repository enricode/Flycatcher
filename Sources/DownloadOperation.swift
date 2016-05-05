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
  var request: FlycatcherRequest!
  var result: FlycatcherResult!
  var acquaintanceRequests: [FlycatcherRequest] = []
  
  var expectedSize: Int = 0
  var currentSize: Int = 0

  private var _ready = false {
    willSet {
      willChangeValueForKey("isReady")
    }
    didSet {
      didChangeValueForKey("isReady")
    }
  }
  override var ready: Bool {
    return _ready
  }
  
  private var _executing = false {
    willSet {
      willChangeValueForKey("isExecuting")
    }
    didSet {
      didChangeValueForKey("isExecuting")
    }
  }
  override var executing: Bool {
    return _executing
  }
  
  private var _finished = false {
    willSet {
      willChangeValueForKey("isFinished")
    }
    didSet {
      didChangeValueForKey("isFinished")
    }
  }
  override var finished: Bool {
    return self.cancelled == true ? true : _finished
  }
  
  override var asynchronous: Bool {
    return true
  }
  
  override init() {
    super.init()
  }
  
  init(request: FlycatcherRequest) {
    super.init()
    
    self.request = request
  }
  
  func loadProgress(progress: DownloadProgress) {
    if let progressClosure = request.progress {
      progressClosure(progress)
    }
  }
  
  func loadReady() {
    _ready = true
  }
  
  func loadStarted() {
    _executing = true
  }
  
  func loadFinished() {
    _finished = true
  }
  
  func loadCancelled() {
    self.result = .Error(self.request.partialResult.resource, .LoadCanceled)
    cancel()
  }
}

class FlycatcherDownloadOperation: DownloadOperation, DownloadOperationProtocol {
  var sessionDataTask: NSURLSessionDataTask!
  var receivedData: NSMutableData?
  
  /// The last time that the resource has been requested
  var touched: NSDate = NSDate()
  
  var resourceSize: DownloadProgress? {
    didSet {
      // Has finished?
      if resourceSize?.current == resourceSize?.total {
        var resource = self.request.partialResult.resource
        resource.resourceData = receivedData
        resource.downloadedAt = NSDate(timeIntervalSinceNow: 0)
        
        // Tell the operation to conclude
        result = .Success(resource)
        loadFinished()
      }
      else {
        loadProgress(resourceSize!)
      }
    }
  }
  
  override init(request: FlycatcherRequest) {
    super.init(request: request)
    
    setupLoad()
  }
  
  /*override func main() {
    if cancelled {
      return
    }
    
    self.loadStarted()
    
    if !cancelled {
      sessionDataTask.resume()
    }
    else {
      sessionDataTask.cancel()
    }
  }*/
  
  override func start() {
    if cancelled {
      loadFinished()
      return
    }
    
    sessionDataTask.resume()
    
    main()
  }
  
  func setupLoad() {
    // Normalized resource url must be present
    guard let downloadURL = self.request.partialResult.resource.normalizedURL else {
      debugPrint("Cannot download resource. The URL is nil")
      
      result = .Error(self.request.partialResult.resource, .InvalidURL)
      loadCancelled()
      
      return
    }
    
    // Create session and request
    let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate: self, delegateQueue: nil)
    let URLrequest = NSMutableURLRequest(URL: downloadURL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: Double(self.request.downloadTimeout))
    URLrequest.allowsCellularAccess = request.cellularDataAllowed
    
    // Create session data task and start connecting
    sessionDataTask = session.dataTaskWithRequest(URLrequest)
    
    // Tell the operation that loading is started
    self.loadReady()
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
    
    if let httpResponse = (response as? NSHTTPURLResponse) {
      switch httpResponse.statusCode {
      case 200...299:
        completionHandler(.Allow)
      case 300...399:
        completionHandler(.Allow)
      case 400...499:
        result = .Error(self.request.partialResult.resource, .ResourceNotFound)
        cancel()
        
        completionHandler(.Cancel)
      case 500...599:
        result = .Error(self.request.partialResult.resource, .ServerError)
        cancel()
        
        completionHandler(.Cancel)
      default:
        completionHandler(.Allow)
      }
    }
  }
}