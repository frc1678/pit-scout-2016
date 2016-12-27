//
//  NSFileManager+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 8/26/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

<<<<<<< HEAD
extension FileManager {

    func enumerateContentsOfDirectory(atPath path: String, orderedByProperty property: String, ascending: Bool, usingBlock block: (URL, Int, inout Bool) -> Void ) {

        let directoryURL = URL(fileURLWithPath: path)
        do {
            let contents = try self.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [URLResourceKey(rawValue: property)], options: FileManager.DirectoryEnumerationOptions())
            let sortedContents = contents.sorted(by: {(URL1: URL, URL2: URL) -> Bool in
=======
extension NSFileManager {

    func enumerateContentsOfDirectoryAtPath(path: String, orderedByProperty property: String, ascending: Bool, usingBlock block: (NSURL, Int, inout Bool) -> Void ) {

        let directoryURL = NSURL(fileURLWithPath: path)
        do {
            let contents = try self.contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: [property], options: NSDirectoryEnumerationOptions())
            let sortedContents = contents.sort({(URL1: NSURL, URL2: NSURL) -> Bool in
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                
                // Maybe there's a better way to do this. See: http://stackoverflow.com/questions/25502914/comparing-anyobject-in-swift
                
                var value1 : AnyObject?
                do {
<<<<<<< HEAD
                    try (URL1 as NSURL).getResourceValue(&value1, forKey: URLResourceKey(rawValue: property))
=======
                    try URL1.getResourceValue(&value1, forKey: property);
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                } catch {
                    return true
                }
                var value2 : AnyObject?
                do {
<<<<<<< HEAD
                    try (URL2 as NSURL).getResourceValue(&value2, forKey: URLResourceKey(rawValue: property))
=======
                    try URL2.getResourceValue(&value2, forKey: property);
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                } catch {
                    return false
                }
                
                if let string1 = value1 as? String, let string2 = value2 as? String {
                    return ascending ? string1 < string2 : string2 < string1
                }
                
<<<<<<< HEAD
                if let date1 = value1 as? Date, let date2 = value2 as? Date {
=======
                if let date1 = value1 as? NSDate, let date2 = value2 as? NSDate {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                    return ascending ? date1 < date2 : date2 < date1
                }
                
                if let number1 = value1 as? NSNumber, let number2 = value2 as? NSNumber {
                    return ascending ? number1 < number2 : number2 < number1
                }
                
                return false
            })
            
<<<<<<< HEAD
            for (i, v) in sortedContents.enumerated() {
=======
            for (i, v) in sortedContents.enumerate() {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                var stop : Bool = false
                block(v, i, &stop)
                if stop { break }
            }

        } catch {
<<<<<<< HEAD
            Log.error(message: "Failed to list directory", error: error)
=======
            Log.error("Failed to list directory", error as NSError)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        }
    }

}

<<<<<<< HEAD
func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == ComparisonResult.orderedAscending
=======
func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
}
