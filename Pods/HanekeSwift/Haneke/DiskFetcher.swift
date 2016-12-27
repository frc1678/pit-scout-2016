//
//  DiskFetcher.swift
//  Haneke
//
//  Created by Joan Romano on 9/16/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

extension HanekeGlobals {

    // It'd be better to define this in the DiskFetcher class but Swift doesn't allow to declare an enum in a generic type
    public struct DiskFetcher {
        
        public enum ErrorCode : Int {
<<<<<<< HEAD
            case invalidData = -500
=======
            case InvalidData = -500
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        }
        
    }
    
}

<<<<<<< HEAD
open class DiskFetcher<T : DataConvertible> : Fetcher<T> {
=======
public class DiskFetcher<T : DataConvertible> : Fetcher<T> {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    
    let path: String
    var cancelled = false
    
    public init(path: String) {
        self.path = path
        let key = path
        super.init(key: key)
    }
    
    // MARK: Fetcher
    
<<<<<<< HEAD
    
    open override func fetch(failure fail: @escaping ((Error?) -> ()), success succeed: @escaping (T.Result) -> ()) {
        self.cancelled = false
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { [weak self] in
=======
    public override func fetch(failure fail: ((NSError?) -> ()), success succeed: (T.Result) -> ()) {
        self.cancelled = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] in
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            if let strongSelf = self {
                strongSelf.privateFetch(failure: fail, success: succeed)
            }
        })
    }
    
<<<<<<< HEAD
    open override func cancelFetch() {
=======
    public override func cancelFetch() {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.cancelled = true
    }
    
    // MARK: Private
    
<<<<<<< HEAD
    fileprivate func privateFetch(failure fail: @escaping ((Error?) -> ()), success succeed: @escaping (T.Result) -> ()) {
=======
    private func privateFetch(failure fail: ((NSError?) -> ()), success succeed: (T.Result) -> ()) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        if self.cancelled {
            return
        }
        
<<<<<<< HEAD
        let data : Data
        do {
            data = try Data(contentsOf: URL(fileURLWithPath: self.path), options: Data.ReadingOptions())
        } catch {
            DispatchQueue.main.async {
                if self.cancelled {
                    return
                }
                fail(error)
=======
        let data : NSData
        do {
            data = try NSData(contentsOfFile: self.path, options: NSDataReadingOptions())
        } catch {
            dispatch_async(dispatch_get_main_queue()) {
                fail(error as NSError)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            }
            return
        }
        
        if self.cancelled {
            return
        }
        
        guard let value : T.Result = T.convertFromData(data) else {
            let localizedFormat = NSLocalizedString("Failed to convert value from data at path %@", comment: "Error description")
            let description = String(format:localizedFormat, self.path)
<<<<<<< HEAD
            let error = errorWithCode(HanekeGlobals.DiskFetcher.ErrorCode.invalidData.rawValue, description: description)
            DispatchQueue.main.async {
=======
            let error = errorWithCode(HanekeGlobals.DiskFetcher.ErrorCode.InvalidData.rawValue, description: description)
            dispatch_async(dispatch_get_main_queue()) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                fail(error)
            }
            return
        }
        
<<<<<<< HEAD
        DispatchQueue.main.async(execute: {
=======
        dispatch_async(dispatch_get_main_queue(), {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            if self.cancelled {
                return
            }
            succeed(value)
        })
    }
}
