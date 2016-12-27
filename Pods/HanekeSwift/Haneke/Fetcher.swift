//
//  Fetcher.swift
//  Haneke
//
//  Created by Hermes Pique on 9/9/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

// See: http://stackoverflow.com/questions/25915306/generic-closure-in-protocol
<<<<<<< HEAD
open class Fetcher<T : DataConvertible> {

    open let key: String
    
    public init(key: String) {
        self.key = key
    }
    
    open func fetch(failure fail: @escaping ((Error?) -> ()), success succeed: @escaping (T.Result) -> ()) {}
    
    open func cancelFetch() {}
=======
public class Fetcher<T : DataConvertible> {

    public let key: String
    
    init(key: String) {
        self.key = key
    }
    
    func fetch(failure fail: ((NSError?) -> ()), success succeed: (T.Result) -> ()) {}
    
    func cancelFetch() {}
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
}

class SimpleFetcher<T : DataConvertible> : Fetcher<T> {
    
    let getValue : () -> T.Result
    
<<<<<<< HEAD
    init(key: String, value getValue : @autoclosure @escaping () -> T.Result) {
=======
    init(key: String, @autoclosure(escaping) value getValue : () -> T.Result) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.getValue = getValue
        super.init(key: key)
    }
    
<<<<<<< HEAD
    override func fetch(failure fail: @escaping ((Error?) -> ()), success succeed: @escaping (T.Result) -> ()) {
=======
    override func fetch(failure fail: ((NSError?) -> ()), success succeed: (T.Result) -> ()) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        let value = getValue()
        succeed(value)
    }
    
    override func cancelFetch() {}
    
}
