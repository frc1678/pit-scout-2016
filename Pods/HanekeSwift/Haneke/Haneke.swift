//
//  Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 9/9/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

public struct HanekeGlobals {
    
    public static let Domain = "io.haneke"
    
}

public struct Shared {
    
    public static var imageCache : Cache<UIImage> {
        struct Static {
            static let name = "shared-images"
            static let cache = Cache<UIImage>(name: name)
        }
        return Static.cache
    }
    
<<<<<<< HEAD
    public static var dataCache : Cache<Data> {
        struct Static {
            static let name = "shared-data"
            static let cache = Cache<Data>(name: name)
=======
    public static var dataCache : Cache<NSData> {
        struct Static {
            static let name = "shared-data"
            static let cache = Cache<NSData>(name: name)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        }
        return Static.cache
    }
    
    public static var stringCache : Cache<String> {
        struct Static {
            static let name = "shared-strings"
            static let cache = Cache<String>(name: name)
        }
        return Static.cache
    }
    
    public static var JSONCache : Cache<JSON> {
        struct Static {
            static let name = "shared-json"
            static let cache = Cache<JSON>(name: name)
        }
        return Static.cache
    }
<<<<<<< HEAD
}

func errorWithCode(_ code: Int, description: String) -> Error {
    let userInfo = [NSLocalizedDescriptionKey: description]
    return NSError(domain: HanekeGlobals.Domain, code: code, userInfo: userInfo) as Error
=======
    
    
}

func errorWithCode(code: Int, description: String) -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: description]
    return NSError(domain: HanekeGlobals.Domain, code: code, userInfo: userInfo)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
}
