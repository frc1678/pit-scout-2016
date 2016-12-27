//
//  NetworkFetcher.swift
//  Haneke
//
//  Created by Hermes Pique on 9/12/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

extension HanekeGlobals {
    
    // It'd be better to define this in the NetworkFetcher class but Swift doesn't allow to declare an enum in a generic type
    public struct NetworkFetcher {

        public enum ErrorCode : Int {
<<<<<<< HEAD
            case invalidData = -400
            case missingData = -401
            case invalidStatusCode = -402
=======
            case InvalidData = -400
            case MissingData = -401
            case InvalidStatusCode = -402
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        }
        
    }
    
}

<<<<<<< HEAD
open class NetworkFetcher<T : DataConvertible> : Fetcher<T> {
    
    let URL : Foundation.URL
    
    public init(URL : Foundation.URL) {
=======
public class NetworkFetcher<T : DataConvertible> : Fetcher<T> {
    
    let URL : NSURL
    
    public init(URL : NSURL) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.URL = URL

        let key =  URL.absoluteString
        super.init(key: key)
    }
    
<<<<<<< HEAD
    open var session : URLSession { return URLSession.shared }
    
    var task : URLSessionDataTask? = nil
=======
    public var session : NSURLSession { return NSURLSession.sharedSession() }
    
    var task : NSURLSessionDataTask? = nil
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    
    var cancelled = false
    
    // MARK: Fetcher
    
<<<<<<< HEAD
    open override func fetch(failure fail: @escaping ((Error?) -> ()), success succeed: @escaping (T.Result) -> ()) {
        self.cancelled = false
        self.task = self.session.dataTask(with: self.URL) {[weak self] (data, response, error) -> Void in
            if let strongSelf = self {
                strongSelf.onReceive(data: data, response: response, error: error, failure: fail, success: succeed)
=======
    public override func fetch(failure fail : ((NSError?) -> ()), success succeed : (T.Result) -> ()) {
        self.cancelled = false
        self.task = self.session.dataTaskWithURL(self.URL) {[weak self] (data, response, error) -> Void in
            if let strongSelf = self {
                strongSelf.onReceiveData(data, response: response, error: error, failure: fail, success: succeed)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            }
        }
        self.task?.resume()
    }
    
<<<<<<< HEAD
    open override func cancelFetch() {
=======
    public override func cancelFetch() {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.task?.cancel()
        self.cancelled = true
    }
    
    // MARK: Private
    
<<<<<<< HEAD
    fileprivate func onReceive(data: Data!, response: URLResponse!, error: Error!, failure fail: @escaping ((Error?) -> ()), success succeed: @escaping (T.Result) -> ()) {
=======
    private func onReceiveData(data: NSData!, response: NSURLResponse!, error: NSError!, failure fail: ((NSError?) -> ()), success succeed: (T.Result) -> ()) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f

        if cancelled { return }
        
        let URL = self.URL
        
        if let error = error {
<<<<<<< HEAD
            if ((error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorCancelled) { return }
            
            Log.debug(message: "Request \(URL.absoluteString) failed", error: error)
            DispatchQueue.main.async(execute: { fail(error) })
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse , !httpResponse.hnk_isValidStatusCode() {
            let description = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            self.failWithCode(.invalidStatusCode, localizedDescription: description, failure: fail)
            return
        }

        if !response.hnk_validateLength(ofData: data) {
            let localizedFormat = NSLocalizedString("Request expected %ld bytes and received %ld bytes", comment: "Error description")
            let description = String(format:localizedFormat, response.expectedContentLength, data.count)
            self.failWithCode(.missingData, localizedDescription: description, failure: fail)
=======
            if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) { return }
            
            Log.debug("Request \(URL.absoluteString) failed", error)
            dispatch_async(dispatch_get_main_queue(), { fail(error) })
            return
        }
        
        guard let httpResponse = response as? NSHTTPURLResponse else {
            Log.debug("Request \(URL.absoluteString) received unknown response \(response)")
            return
        }
        
        if httpResponse.statusCode != 200 {
            let description = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
            self.failWithCode(.InvalidStatusCode, localizedDescription: description, failure: fail)
            return
        }
        
        if !httpResponse.hnk_validateLengthOfData(data) {
            let localizedFormat = NSLocalizedString("Request expected %ld bytes and received %ld bytes", comment: "Error description")
            let description = String(format:localizedFormat, response.expectedContentLength, data.length)
            self.failWithCode(.MissingData, localizedDescription: description, failure: fail)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            return
        }
        
        guard let value = T.convertFromData(data) else {
            let localizedFormat = NSLocalizedString("Failed to convert value from data at URL %@", comment: "Error description")
            let description = String(format:localizedFormat, URL.absoluteString)
<<<<<<< HEAD
            self.failWithCode(.invalidData, localizedDescription: description, failure: fail)
            return
        }

        DispatchQueue.main.async { succeed(value) }

    }
    
    fileprivate func failWithCode(_ code: HanekeGlobals.NetworkFetcher.ErrorCode, localizedDescription: String, failure fail: @escaping ((Error?) -> ())) {
        let error = errorWithCode(code.rawValue, description: localizedDescription)
        Log.debug(message: localizedDescription, error: error)
        DispatchQueue.main.async { fail(error) }
=======
            self.failWithCode(.InvalidData, localizedDescription: description, failure: fail)
            return
        }

        dispatch_async(dispatch_get_main_queue()) { succeed(value) }

    }
    
    private func failWithCode(code: HanekeGlobals.NetworkFetcher.ErrorCode, localizedDescription: String, failure fail: ((NSError?) -> ())) {
        let error = errorWithCode(code.rawValue, description: localizedDescription)
        Log.debug(localizedDescription, error)
        dispatch_async(dispatch_get_main_queue()) { fail(error) }
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    }
}
