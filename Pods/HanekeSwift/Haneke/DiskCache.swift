//
//  DiskCache.swift
//  Haneke
//
//  Created by Hermes Pique on 8/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

<<<<<<< HEAD
open class DiskCache {
    
    open class func basePath() -> String {
        let cachesPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let hanekePathComponent = HanekeGlobals.Domain
        let basePath = (cachesPath as NSString).appendingPathComponent(hanekePathComponent)
=======
public class DiskCache {
    
    public class func basePath() -> String {
        let cachesPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        let hanekePathComponent = HanekeGlobals.Domain
        let basePath = (cachesPath as NSString).stringByAppendingPathComponent(hanekePathComponent)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        // TODO: Do not recaculate basePath value
        return basePath
    }
    
<<<<<<< HEAD
    open let path: String

    open var size : UInt64 = 0

    open var capacity : UInt64 = 0 {
        didSet {
            self.cacheQueue.async(execute: {
=======
    public let path: String

    public var size : UInt64 = 0

    public var capacity : UInt64 = 0 {
        didSet {
            dispatch_async(self.cacheQueue, {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                self.controlCapacity()
            })
        }
    }

<<<<<<< HEAD
    open lazy var cacheQueue : DispatchQueue = {
        let queueName = HanekeGlobals.Domain + "." + (self.path as NSString).lastPathComponent
        let cacheQueue = DispatchQueue(label: queueName, attributes: [])
=======
    public lazy var cacheQueue : dispatch_queue_t = {
        let queueName = HanekeGlobals.Domain + "." + (self.path as NSString).lastPathComponent
        let cacheQueue = dispatch_queue_create(queueName, nil)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        return cacheQueue
    }()
    
    public init(path: String, capacity: UInt64 = UINT64_MAX) {
        self.path = path
        self.capacity = capacity
<<<<<<< HEAD
        self.cacheQueue.async(execute: {
=======
        dispatch_async(self.cacheQueue, {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            self.calculateSize()
            self.controlCapacity()
        })
    }
    
<<<<<<< HEAD
    open func setData( _ getData: @autoclosure @escaping () -> Data?, key: String) {
        cacheQueue.async(execute: {
            if let data = getData() {
                self.setDataSync(data, key: key)
            } else {
                Log.error(message: "Failed to get data for key \(key)")
=======
    public func setData(@autoclosure(escaping) getData: () -> NSData?, key: String) {
        dispatch_async(cacheQueue, {
            if let data = getData() {
                self.setDataSync(data, key: key)
            } else {
                Log.error("Failed to get data for key \(key)")
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            }
        })
    }
    
<<<<<<< HEAD
    @discardableResult open func fetchData(key: String, failure fail: ((Error?) -> ())? = nil, success succeed: @escaping (Data) -> ()) {
        cacheQueue.async {
            let path = self.path(forKey: key)
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions())
                DispatchQueue.main.async {
                    succeed(data)
                }
                self.updateDiskAccessDate(atPath: path)
            } catch {
                if let block = fail {
                    DispatchQueue.main.async {
                        block(error)
=======
    public func fetchData(key key: String, failure fail: ((NSError?) -> ())? = nil, success succeed: (NSData) -> ()) {
        dispatch_async(cacheQueue) {
            let path = self.pathForKey(key)
            do {
                let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
                dispatch_async(dispatch_get_main_queue()) {
                    succeed(data)
                }
                self.updateDiskAccessDateAtPath(path)
            } catch {
                if let block = fail {
                    dispatch_async(dispatch_get_main_queue()) {
                        block(error as NSError)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                    }
                }
            }
        }
    }

<<<<<<< HEAD
    open func removeData(with key: String) {
        cacheQueue.async(execute: {
            let path = self.path(forKey: key)
            self.removeFile(atPath: path)
        })
    }
    
    open func removeAllData(_ completion: (() -> ())? = nil) {
        let fileManager = FileManager.default
        let cachePath = self.path
        cacheQueue.async(execute: {
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: cachePath)
                for pathComponent in contents {
                    let path = (cachePath as NSString).appendingPathComponent(pathComponent)
                    do {
                        try fileManager.removeItem(atPath: path)
                    } catch {
                        Log.error(message: "Failed to remove path \(path)", error: error)
=======
    public func removeData(key: String) {
        dispatch_async(cacheQueue, {
            let path = self.pathForKey(key)
            self.removeFileAtPath(path)
        })
    }
    
    public func removeAllData() {
        let fileManager = NSFileManager.defaultManager()
        let cachePath = self.path
        dispatch_async(cacheQueue, {
            do {
                let contents = try fileManager.contentsOfDirectoryAtPath(cachePath)
                for pathComponent in contents {
                    let path = (cachePath as NSString).stringByAppendingPathComponent(pathComponent)
                    do {
                        try fileManager.removeItemAtPath(path)
                    } catch {
                        Log.error("Failed to remove path \(path)", error as NSError)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                    }
                }
                self.calculateSize()
            } catch {
<<<<<<< HEAD
                Log.error(message: "Failed to list directory", error: error)
            }
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
=======
                Log.error("Failed to list directory", error as NSError)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            }
        })
    }

<<<<<<< HEAD
    open func updateAccessDate( _ getData: @autoclosure @escaping () -> Data?, key: String) {
        cacheQueue.async(execute: {
            let path = self.path(forKey: key)
            let fileManager = FileManager.default
            if (!(fileManager.fileExists(atPath: path) && self.updateDiskAccessDate(atPath: path))){
                if let data = getData() {
                    self.setDataSync(data, key: key)
                } else {
                    Log.error(message: "Failed to get data for key \(key)")
=======
    public func updateAccessDate(@autoclosure(escaping) getData: () -> NSData?, key: String) {
        dispatch_async(cacheQueue, {
            let path = self.pathForKey(key)
            let fileManager = NSFileManager.defaultManager()
            if (!self.updateDiskAccessDateAtPath(path) && !fileManager.fileExistsAtPath(path)){
                if let data = getData() {
                    self.setDataSync(data, key: key)
                } else {
                    Log.error("Failed to get data for key \(key)")
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                }
            }
        })
    }

<<<<<<< HEAD
    open func path(forKey key: String) -> String {
        let escapedFilename = key.escapedFilename()
        let filename = escapedFilename.characters.count < Int(NAME_MAX) ? escapedFilename : key.MD5Filename()
        let keyPath = (self.path as NSString).appendingPathComponent(filename)
=======
    public func pathForKey(key: String) -> String {
        let escapedFilename = key.escapedFilename()
        let filename = escapedFilename.characters.count < Int(NAME_MAX) ? escapedFilename : key.MD5Filename()
        let keyPath = (self.path as NSString).stringByAppendingPathComponent(filename)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        return keyPath
    }
    
    // MARK: Private
    
<<<<<<< HEAD
    fileprivate func calculateSize() {
        let fileManager = FileManager.default
        size = 0
        let cachePath = self.path
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: cachePath)
            for pathComponent in contents {
                let path = (cachePath as NSString).appendingPathComponent(pathComponent)
                do {
                    let attributes: [FileAttributeKey: Any] = try fileManager.attributesOfItem(atPath: path)
                    if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                        size += fileSize
                    }
                } catch {
                    Log.error(message: "Failed to list directory", error: error)
                }
            }
            
        } catch {
            Log.error(message: "Failed to list directory", error: error)
        }
    }
    
    fileprivate func controlCapacity() {
        if self.size <= self.capacity { return }
        
        let fileManager = FileManager.default
        let cachePath = self.path
        fileManager.enumerateContentsOfDirectory(atPath: cachePath, orderedByProperty: URLResourceKey.contentModificationDateKey.rawValue, ascending: true) { (URL : URL, _, stop : inout Bool) -> Void in
            
            self.removeFile(atPath: URL.path)

            stop = self.size <= self.capacity
        }
    }
    
    fileprivate func setDataSync(_ data: Data, key: String) {
        let path = self.path(forKey: key)
        let fileManager = FileManager.default
        let previousAttributes : [FileAttributeKey: Any]? = try? fileManager.attributesOfItem(atPath: path)
        
        do {
            try data.write(to: URL(fileURLWithPath: path), options: Data.WritingOptions.atomicWrite)
        } catch {
            Log.error(message: "Failed to write key \(key)", error: error)
        }
        
        if let attributes = previousAttributes {
            if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                substract(size: fileSize)
            }
        }
        self.size += UInt64(data.count)
        self.controlCapacity()
    }
    
    @discardableResult fileprivate func updateDiskAccessDate(atPath path: String) -> Bool {
        let fileManager = FileManager.default
        let now = Date()
        do {
            try fileManager.setAttributes([FileAttributeKey.modificationDate : now], ofItemAtPath: path)
            return true
        } catch {
            Log.error(message: "Failed to update access date", error: error)
=======
    private func calculateSize() {
        let fileManager = NSFileManager.defaultManager()
        size = 0
        let cachePath = self.path
        do {
            let contents = try fileManager.contentsOfDirectoryAtPath(cachePath)
            for pathComponent in contents {
                let path = (cachePath as NSString).stringByAppendingPathComponent(pathComponent)
                do {
                    let attributes : NSDictionary = try fileManager.attributesOfItemAtPath(path)
                    size += attributes.fileSize()
                } catch {
                    Log.error("Failed to read file size of \(path)", error as NSError)
                }
            }

        } catch {
            Log.error("Failed to list directory", error as NSError)
        }
    }
    
    private func controlCapacity() {
        if self.size <= self.capacity { return }
        
        let fileManager = NSFileManager.defaultManager()
        let cachePath = self.path
        fileManager.enumerateContentsOfDirectoryAtPath(cachePath, orderedByProperty: NSURLContentModificationDateKey, ascending: true) { (URL : NSURL, _, inout stop : Bool) -> Void in
            
            if let path = URL.path {
                self.removeFileAtPath(path)

                stop = self.size <= self.capacity
            }
        }
    }
    
    private func setDataSync(data: NSData, key: String) {
        let path = self.pathForKey(key)
        let fileManager = NSFileManager.defaultManager()
        let previousAttributes : NSDictionary? = try? fileManager.attributesOfItemAtPath(path)
        
        do {
            try data.writeToFile(path, options: NSDataWritingOptions.AtomicWrite)
        } catch {
            Log.error("Failed to write key \(key)", error as NSError)
        }
        
        if let attributes = previousAttributes {
            self.size -= attributes.fileSize()
        }
        self.size += UInt64(data.length)
        self.controlCapacity()
    }
    
    private func updateDiskAccessDateAtPath(path: String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let now = NSDate()
        do {
            try fileManager.setAttributes([NSFileModificationDate : now], ofItemAtPath: path)
            return true
        } catch {
            Log.error("Failed to update access date", error as NSError)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            return false
        }
    }
    
<<<<<<< HEAD
    fileprivate func removeFile(atPath path: String) {
        let fileManager = FileManager.default
        do {
            let attributes: [FileAttributeKey: Any] = try fileManager.attributesOfItem(atPath: path)
            do {
                try fileManager.removeItem(atPath: path)
                if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                    substract(size: fileSize)
                }
            } catch {
                Log.error(message: "Failed to remove file", error: error)
            }
        } catch {
            if isNoSuchFileError(error) {
                Log.debug(message: "File not found", error: error)
            } else {
                Log.error(message: "Failed to remove file", error: error)
            }
        }
    }

    fileprivate func substract(size : UInt64) {
        if (self.size >= size) {
            self.size -= size
        } else {
            Log.error(message: "Disk cache size (\(self.size)) is smaller than size to substract (\(size))")
            self.size = 0
        }
    }
}

private func isNoSuchFileError(_ error : Error?) -> Bool {
    if let error = error {
        return NSCocoaErrorDomain == (error as NSError).domain && (error as NSError).code == NSFileReadNoSuchFileError
=======
    private func removeFileAtPath(path: String) {
        let fileManager = NSFileManager.defaultManager()
        do {
            let attributes : NSDictionary =  try fileManager.attributesOfItemAtPath(path)
            let fileSize = attributes.fileSize()
            do {
                try fileManager.removeItemAtPath(path)
                self.size -= fileSize
            } catch {
                Log.error("Failed to remove file", error as NSError)
            }
        } catch {
            let castedError = error as NSError
            if isNoSuchFileError(castedError) {
                Log.debug("File not found", castedError)
            } else {
                Log.error("Failed to remove file", castedError)
            }
        }
    }
}

private func isNoSuchFileError(error : NSError?) -> Bool {
    if let error = error {
        return NSCocoaErrorDomain == error.domain && error.code == NSFileReadNoSuchFileError
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    }
    return false
}
