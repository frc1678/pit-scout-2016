//
//  Fetch.swift
//  Haneke
//
//  Created by Hermes Pique on 9/28/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

enum FetchState<T> {
<<<<<<< HEAD
    case pending
    // Using Wrapper as a workaround for error 'unimplemented IR generation feature non-fixed multi-payload enum layout'
    // See: http://swiftradar.tumblr.com/post/88314603360/swift-fails-to-compile-enum-with-two-data-cases
    // See: http://owensd.io/2014/08/06/fixed-enum-layout.html
    case success(Wrapper<T>)
    case failure(Error?)
}

open class Fetch<T> {
    
    public typealias Succeeder = (T) -> ()
    
    public typealias Failer = (Error?) -> ()
    
    fileprivate var onSuccess : Succeeder?
    
    fileprivate var onFailure : Failer?
    
    fileprivate var state : FetchState<T> = FetchState.pending
    
    public init() {}
    
    @discardableResult open func onSuccess(_ onSuccess: @escaping Succeeder) -> Self {
        self.onSuccess = onSuccess
        switch self.state {
        case FetchState.success(let wrapper):
=======
    case Pending
    // Using Wrapper as a workaround for error 'unimplemented IR generation feature non-fixed multi-payload enum layout'
    // See: http://swiftradar.tumblr.com/post/88314603360/swift-fails-to-compile-enum-with-two-data-cases
    // See: http://owensd.io/2014/08/06/fixed-enum-layout.html
    case Success(Wrapper<T>)
    case Failure(NSError?)
}

public class Fetch<T> {
    
    public typealias Succeeder = (T) -> ()
    
    public typealias Failer = (NSError?) -> ()
    
    private var onSuccess : Succeeder?
    
    private var onFailure : Failer?
    
    private var state : FetchState<T> = FetchState.Pending
    
    public init() {}
    
    public func onSuccess(onSuccess: Succeeder) -> Self {
        self.onSuccess = onSuccess
        switch self.state {
        case FetchState.Success(let wrapper):
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            onSuccess(wrapper.value)
        default:
            break
        }
        return self
    }
    
<<<<<<< HEAD
    @discardableResult open func onFailure(_ onFailure: @escaping Failer) -> Self {
        self.onFailure = onFailure
        switch self.state {
        case FetchState.failure(let error):
=======
    public func onFailure(onFailure: Failer) -> Self {
        self.onFailure = onFailure
        switch self.state {
        case FetchState.Failure(let error):
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            onFailure(error)
        default:
            break
        }
        return self
    }
    
<<<<<<< HEAD
    func succeed(_ value: T) {
        self.state = FetchState.success(Wrapper(value))
        self.onSuccess?(value)
    }
    
    func fail(_ error: Error? = nil) {
        self.state = FetchState.failure(error)
=======
    func succeed(value: T) {
        self.state = FetchState.Success(Wrapper(value))
        self.onSuccess?(value)
    }
    
    func fail(error: NSError? = nil) {
        self.state = FetchState.Failure(error)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.onFailure?(error)
    }
    
    var hasFailed : Bool {
        switch self.state {
<<<<<<< HEAD
        case FetchState.failure(_):
=======
        case FetchState.Failure(_):
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            return true
        default:
            return false
            }
    }
    
    var hasSucceeded : Bool {
        switch self.state {
<<<<<<< HEAD
        case FetchState.success(_):
=======
        case FetchState.Success(_):
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            return true
        default:
            return false
        }
    }
    
}

<<<<<<< HEAD
open class Wrapper<T> {
    open let value: T
=======
public class Wrapper<T> {
    public let value: T
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    public init(_ value: T) { self.value = value }
}
