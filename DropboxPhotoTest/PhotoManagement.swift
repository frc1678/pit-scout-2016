//
//  PhotoUploader.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 2/8/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//

import Foundation
<<<<<<< HEAD
//import SwiftyDropbox
=======
import SwiftyDropbox
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
import Firebase
import Haneke

class PhotoManager : NSObject {
    let cache = Shared.dataCache
    var teamNumbers : [Int]
    var mayKeepWorking = true {
        didSet {
            print("mayKeepWorking: \(mayKeepWorking)")
        }
    }
    
<<<<<<< HEAD
    var timer : Timer = Timer()
=======
    var timer : NSTimer = NSTimer()
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    var teamsFirebase : FIRDatabaseReference
    var numberOfPhotosForTeam = [Int: Int]()
    var callbackForPhotoCasheUpdated = { }
    var currentlyNotifyingTeamNumber = 0
    let photoSaver = CustomPhotoAlbum()
    var activeImages = [[String: AnyObject]]()
    let firebaseImageDownloadURLBeginning = "https://firebasestorage.googleapis.com/v0/b/firebase-scouting-2016.appspot.com/o/"
<<<<<<< HEAD
    let firebaseImageDownloadURLEnd = "?alt=media"
=======
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    
    init(teamsFirebase : FIRDatabaseReference, teamNumbers : [Int]) {
        
        self.teamNumbers = teamNumbers
        self.teamsFirebase = teamsFirebase
        for number in teamNumbers {
            self.numberOfPhotosForTeam[number] = 0
        }
        super.init()
    }
    
<<<<<<< HEAD
    func getSharedURLsForTeam(_ num: Int, fetched: @escaping (NSMutableArray?)->()) {
        if self.mayKeepWorking {
            self.cache.fetch(key: "sharedURLs\(num)").onSuccess { (data) -> () in
                if let urls = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSMutableArray {
=======
    func getSharedURLsForTeam(num: Int, fetched: (NSMutableArray?)->()) {
        if self.mayKeepWorking {
            self.cache.fetch(key: "sharedURLs\(num)").onSuccess { (data) -> () in
                if let urls = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSMutableArray {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                    fetched(urls)
                } else {
                    fetched(nil)
                }
                }.onFailure { (E) -> () in
                    print("Failed to fetch URLS for team \(num)")
            }
        }
    }
    
<<<<<<< HEAD
    func updateUrl(_ teamNumber: Int, callback: @escaping (_ i: Int)->()) {
=======
    func updateUrl(teamNumber: Int, callback: (i: Int)->()) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.getSharedURLsForTeam(teamNumber) { [unowned self] (urls) -> () in
            if let oldURLs = urls {
                let i : Int
                if oldURLs.count == 3 {
                    i = 0
                } else if oldURLs.count < 3 {
                    i = oldURLs.count //If there are currently two images, we want i to be 2, because that will be the index of the third image
                } else {
                    print("This should not happen")
                    i = 0
                }
                let url = self.makeURLForTeamNumAndImageIndex(teamNumber, imageIndex: i)
                if oldURLs.count - 1 == i {
                    oldURLs[i] = url
                } else if oldURLs.count == i {
<<<<<<< HEAD
                    oldURLs.add(url)
                } else {
                    oldURLs[i] = url
                } //Old URLs is actually new urls at this point
                self.cache.set(value: NSKeyedArchiver.archivedData(withRootObject: oldURLs), key: "sharedURLs\(teamNumber)", success: { _ in
                    callback(i)
=======
                    oldURLs.addObject(url)
                } else {
                    oldURLs[i] = url
                } //Old URLs is actually new urls at this point
                self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(oldURLs), key: "sharedURLs\(teamNumber)", success: { _ in
                    callback(i: i)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                })
                
            } else {
                print("Could not fetch shared urls for \(teamNumber)")
            }
        }
    }
    
<<<<<<< HEAD
    func putPhotoLinkToFirebase(_ link: String, teamNumber: Int, selectedImage: Bool) {
        let teamFirebase = self.teamsFirebase.child("\(teamNumber)")
        let currentURLs = teamFirebase.child("otherImageUrls")
        currentURLs.observeSingleEvent(of: .value, with: { (snap) -> Void in
            if snap.childrenCount >= 3 {
                currentURLs.child((snap.children.allObjects.first as! FIRDataSnapshot).key).removeValue()
            }
            currentURLs.childByAutoId().setValue(link)

=======
    func putPhotoLinkToFirebase(link: String, teamNumber: Int, selectedImage: Bool) {
        let teamFirebase = self.teamsFirebase.child("\(teamNumber)")
        let currentURLs = teamFirebase.child("otherImageUrls")
        currentURLs.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in
            if snap.childrenCount < 3 {
                currentURLs.childByAutoId().setValue(link)
            }
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            if(selectedImage) {
                teamFirebase.child("selectedImageUrl").setValue(link)
            }
        })
    }
    
<<<<<<< HEAD
    func makeURLForTeamNumAndImageIndex(_ teamNum: Int, imageIndex: Int) -> String {
        return self.firebaseImageDownloadURLBeginning + self.makeFilenameForTeamNumAndIndex(teamNum, imageIndex: imageIndex) + self.firebaseImageDownloadURLEnd
    }
    
    func makeFilenameForTeamNumAndIndex(_ teamNum: Int, imageIndex: Int) -> String {
        return String(teamNum) + "_" + String(imageIndex) + ".png"
    }
    
    func makeURLForFileName(_ fileName: String) -> String {
=======
    func makeURLForTeamNumAndImageIndex(teamNum: Int, imageIndex: Int) -> String {
        return self.firebaseImageDownloadURLBeginning + self.makeFilenameForTeamNumAndIndex(teamNum, imageIndex: imageIndex)
    }
    
    func makeFilenameForTeamNumAndIndex(teamNum: Int, imageIndex: Int) -> String {
        return String(teamNum) + "_" + String(imageIndex) + ".png"
    }
    
    func makeURLForFileName(fileName: String) -> String {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        return self.firebaseImageDownloadURLBeginning + String(fileName)
    }
    
}

extension UIImage {
<<<<<<< HEAD
    public func imageRotatedByDegrees(_ degrees: CGFloat, flip: Bool) -> UIImage {
=======
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing spaaace
<<<<<<< HEAD
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
=======
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
<<<<<<< HEAD
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(degrees));
=======
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
<<<<<<< HEAD
        bitmap?.scaleBy(x: yFlip, y: -1.0)
        bitmap?.draw(cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
=======
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
<<<<<<< HEAD
        return newImage!
    }
}
=======
        return newImage
    }
}
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
