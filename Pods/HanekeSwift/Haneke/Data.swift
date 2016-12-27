//
//  Data.swift
//  Haneke
//
//  Created by Hermes Pique on 9/19/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

// See: http://stackoverflow.com/questions/25922152/not-identical-to-self
public protocol DataConvertible {
<<<<<<< HEAD
    associatedtype Result
    
    static func convertFromData(_ data:Data) -> Result?
=======
    typealias Result
    
    static func convertFromData(data:NSData) -> Result?
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
}

public protocol DataRepresentable {
    
<<<<<<< HEAD
    func asData() -> Data!
}

private let imageSync = NSLock()

extension UIImage : DataConvertible, DataRepresentable {
    
    public typealias Result = UIImage

    // HACK: UIImage data initializer is no longer thread safe. See: https://github.com/AFNetworking/AFNetworking/issues/2572#issuecomment-115854482
    static func safeImageWithData(_ data:Data) -> Result? {
        imageSync.lock()
        let image = UIImage(data:data, scale: scale)
        imageSync.unlock()
        return image
    }
    
    public class func convertFromData(_ data: Data) -> Result? {
        let image = UIImage.safeImageWithData(data)
        return image
    }
    
    public func asData() -> Data! {
        return self.hnk_data() as Data!
    }
    
    fileprivate static let scale = UIScreen.main.scale
    
=======
    func asData() -> NSData!
}

extension UIImage : DataConvertible, DataRepresentable {
    
    public typealias Result = UIImage
    
    public class func convertFromData(data: NSData) -> Result? {
        let image = UIImage(data: data)
        return image
    }
    
    public func asData() -> NSData! {
        return self.hnk_data()
    }
    
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
}

extension String : DataConvertible, DataRepresentable {
    
    public typealias Result = String
    
<<<<<<< HEAD
    public static func convertFromData(_ data: Data) -> Result? {
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        return string as? Result
    }
    
    public func asData() -> Data! {
        return self.data(using: String.Encoding.utf8)
=======
    public static func convertFromData(data: NSData) -> Result? {
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)
        return string as? Result
    }
    
    public func asData() -> NSData! {
        return self.dataUsingEncoding(NSUTF8StringEncoding)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    }
    
}

<<<<<<< HEAD
extension Data : DataConvertible, DataRepresentable {
    
    public typealias Result = Data
    
    public static func convertFromData(_ data: Data) -> Result? {
        return data
    }
    
    public func asData() -> Data! {
=======
extension NSData : DataConvertible, DataRepresentable {
    
    public typealias Result = NSData
    
    public class func convertFromData(data: NSData) -> Result? {
        return data
    }
    
    public func asData() -> NSData! {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        return self
    }
    
}

public enum JSON : DataConvertible, DataRepresentable {
    public typealias Result = JSON
    
    case Dictionary([String:AnyObject])
    case Array([AnyObject])
    
<<<<<<< HEAD
    public static func convertFromData(_ data: Data) -> Result? {
        do {
            let object : Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
=======
    public static func convertFromData(data: NSData) -> Result? {
        do {
            let object : AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            switch (object) {
            case let dictionary as [String:AnyObject]:
                return JSON.Dictionary(dictionary)
            case let array as [AnyObject]:
                return JSON.Array(array)
            default:
                return nil
            }
        } catch {
<<<<<<< HEAD
            Log.error(message: "Invalid JSON data", error: error)
=======
            Log.error("Invalid JSON data", error as NSError)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            return nil
        }
    }
    
<<<<<<< HEAD
    public func asData() -> Data! {
        switch (self) {
        case .Dictionary(let dictionary):
            return try? JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions())
        case .Array(let array):
            return try? JSONSerialization.data(withJSONObject: array, options: JSONSerialization.WritingOptions())
=======
    public func asData() -> NSData! {
        switch (self) {
        case .Dictionary(let dictionary):
            return try? NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions())
        case .Array(let array):
            return try? NSJSONSerialization.dataWithJSONObject(array, options: NSJSONWritingOptions())
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        }
    }
    
    public var array : [AnyObject]! {
        switch (self) {
        case .Dictionary(_):
            return nil
        case .Array(let array):
            return array
        }
    }
    
    public var dictionary : [String:AnyObject]! {
        switch (self) {
        case .Dictionary(let dictionary):
            return dictionary
        case .Array(_):
            return nil
        }
    }
    
}
