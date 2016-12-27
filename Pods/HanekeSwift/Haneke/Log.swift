//
//  Log.swift
//  Haneke
//
//  Created by Hermes Pique on 11/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

struct Log {
    
<<<<<<< HEAD
    fileprivate static let Tag = "[HANEKE]"
    
    fileprivate enum Level : String {
=======
    private static let Tag = "[HANEKE]"
    
    private enum Level : String {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        case Debug = "[DEBUG]"
        case Error = "[ERROR]"
    }
    
<<<<<<< HEAD
    fileprivate static func log(_ level: Level, _ message: @autoclosure () -> String, _ error: Error? = nil) {
        if let error = error {
            print("\(Tag)\(level.rawValue) \(message()) with error \(error)")
        } else {
            print("\(Tag)\(level.rawValue) \(message())")
        }
    }
    
    static func debug(message: @autoclosure () -> String, error: Error? = nil) {
=======
    private static func log(level: Level, @autoclosure _ message: () -> String, _ error: NSError? = nil) {
        if let error = error {
            NSLog("%@%@ %@ with error %@", Tag, level.rawValue, message(), error)
        } else {
            NSLog("%@%@ %@", Tag, level.rawValue, message())
        }
    }
    
    static func debug(@autoclosure message: () -> String, _ error: NSError? = nil) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        #if DEBUG
            log(.Debug, message, error)
        #endif
    }
    
<<<<<<< HEAD
    static func error(message: @autoclosure () -> String, error: Error? = nil) {
=======
    static func error(@autoclosure message: () -> String, _ error: NSError? = nil) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        log(.Error, message, error)
    }
    
}
