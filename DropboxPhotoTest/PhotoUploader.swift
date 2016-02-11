//
//  PhotoUploader.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 2/8/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//

import Foundation
import SwiftyDropbox
import Firebase
import Haneke

class PhotoUploader : NSObject {
    let cache = Shared.dataCache
    let teamNumbers : NSMutableArray
    var filesToUpload : [Int : [[String: AnyObject]]] = [-1:[["-1":"-1"]]] {
        didSet {
            self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(self.filesToUpload), key: "photos")
        }
    }
    var sharedURLs : [Int : NSMutableArray] = [-1:["-1"]] {
        didSet {
            self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(self.sharedURLs), key: "sharedURLs")
        }
    }
    var timer : NSTimer = NSTimer()
    var teamsFirebase : Firebase
    
    init(teamsFirebase : Firebase, teamNumbers : NSMutableArray) {
        self.teamNumbers = teamNumbers
        self.teamsFirebase = teamsFirebase
        for number in teamNumbers {
            self.filesToUpload[number as! Int] = []
            self.sharedURLs[number as! Int] = []
        }
        
        super.init()
        
        self.fetchToUpdate()
        
    }
    
    
    
    func fetchToUpdate() {
        self.cache.fetch(key: "photos").onSuccess { (data) -> () in
            let images = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Int : [[String: AnyObject]]]
            for teamNum in self.teamNumbers {
                if let imagesForTeam = images[teamNum as! Int] {
                    if let files = self.filesToUpload[teamNum as! Int] {
                        if imagesForTeam != files {
                            self.filesToUpload[teamNum as! Int] = imagesForTeam
                        }
                    }
                }
            }
            print("Images Fetched")
            self.cache.fetch(key: "sharedURLs").onSuccess { (data) -> () in
                let urls = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Int: NSMutableArray]
                for teamNum in self.teamNumbers {
                    if let urlsForTeam = urls[teamNum as! Int] {
                        if self.sharedURLs[teamNum as! Int] != nil {
                            if urlsForTeam != self.sharedURLs[teamNum as! Int]! {
                                self.sharedURLs[teamNum as! Int] = urlsForTeam
                            }
                        } else {
                            self.sharedURLs[teamNum as! Int] = urlsForTeam
                        }
                        
                    }
                }
                print("URLs Fetched")
                self.uploadAllPhotos()
                }.onFailure { (E) -> () in
                    print("URLs Not Fetched \(E.debugDescription)")
                    self.sharedURLs = [-2:["-2"]]
                    self.cache.fetch(key: "sharedURLs").onSuccess { (data) -> () in
                        let urls = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Int: NSMutableArray]
                        for teamNum in self.teamNumbers {
                            if let urlsForTeam = urls[teamNum as! Int] {
                                if self.sharedURLs[teamNum as! Int] != nil {
                                    if urlsForTeam != self.sharedURLs[teamNum as! Int]! {
                                        self.sharedURLs[teamNum as! Int] = urlsForTeam
                                    }
                                } else {
                                    self.sharedURLs[teamNum as! Int] = urlsForTeam
                                }
                                
                            }
                        }
                        print("URLs Fetched")
                        self.uploadAllPhotos()
                    }
            }
            }.onFailure { (E) -> () in
                print("Images Not Fetched: \(E.debugDescription)")
        }
        self.fetchPhotosFromDropbox()
    }
    
    func fetchPhotosFromDropbox() {
        if self.isConnectedToNetwork() {
            if let client = Dropbox.authorizedClient {
                for teamNumber in self.teamNumbers {
                    client.files.search(path: "/Public", query: "\(teamNumber)_").response({ (response, error) -> Void in
                        if let result = response {
                            for match in result.matches {
                                let name = match.metadata.name
                                
                                let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
                                    let fileManager = NSFileManager.defaultManager()
                                    let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                                    // generate a unique name for this file in case we've seen it before
                                    let UUID = NSUUID().UUIDString
                                    let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
                                    return directoryURL.URLByAppendingPathComponent(pathComponent)
                                }
                                
                                client.files.download(path: "/Public/\(name)", destination: destination).response { (response, error) in
                                    if let (metadata, url) = response {
                                        print("*** Download file ***")
                                        let data = NSData(contentsOfURL: url)
                                        self.addFileToLineup(data!, fileName: name, teamNumber: teamNumber as! Int)
                                        print("Downloaded file url: \(url)")
                                        print("Downloaded file name: \(metadata.name)")
                                        
                                    } else {
                                        print("Download error for name \(name), error: \(error!)")
                                    }
                                }
                            }
                        } else {
                            //print("Query Error for team \(teamNumber), Error: \(error?.description)")
                        }
                    })
                }
            }
        }
    }
    
    func getSharedURLsForTeamNum(number: Int) -> NSMutableArray {
        return self.sharedURLs[number]!
    }
    
    func getImagesForTeamNum(number: Int) -> [[String: AnyObject]] {
        return self.filesToUpload[number]!
    }
    
    func uploadAllPhotos() {
        if(self.isConnectedToNetwork()) {
            if let client = Dropbox.authorizedClient {
                for teamNumber in self.teamNumbers {
                    if let filesForTeam = self.filesToUpload[teamNumber as! Int] {
                        for file in filesForTeam {
                            let name = file["name"] as! String
                            let data = file["data"] as! NSData
                            var sharedURL = "Not Uploaded"
                            let path = "/Public/\(name)"
                            client.files.upload(path: path, body: data).response { response, error in
                                if let metaData = response {
                                    self.filesToUpload[teamNumber as! Int] = self.filesToUpload[teamNumber as! Int]!.filter({$0["name"] as! String != name})
                                    //Removing the uploaded file from files to upload, this actually works in swift!
                                    print("*** Upload file: \(metaData) ****")
                                    sharedURL = "https://dl.dropboxusercontent.com/u/63662632/\(name)"
                                    self.putPhotoLinkToFirebase(sharedURL, teamNumber: teamNumber as! Int, selectedImage: false)
                                    self.sharedURLs[teamNumber as! Int]![(self.sharedURLs[teamNumber as! Int]?.count)!] = sharedURL //This line is terrible
                                    //print(self.sharedURLs)
                                } else {
                                    client.files.delete(path: path)
                                    self.uploadAllPhotos()
                                    print("Upload Error: \(error?.description)")
                                }
                            }
                        }
                    }
                    
                }
            }
        } else {
            self.checkInternet(self.timer)
        }
        
    }
    func addFileToLineup(fileData : NSData, fileName : String, teamNumber : Int) {
        let fileDict = ["name" : fileName, "data" : fileData]
        if self.filesToUpload[teamNumber] != nil {
            self.filesToUpload[teamNumber]!.append(fileDict)
        } else {
            self.filesToUpload[teamNumber] = [fileDict]
        }
        self.uploadAllPhotos()
    }
    
    func isConnectedToNetwork() -> Bool  {
        let url = NSURL(string: "https://www.google.com/")
        
        let data = NSData(contentsOfURL: url!)
        
        if (data != nil) {
            return(true)
        }
        return(false)
    }
    
    func checkInternet(timer: NSTimer) {
        self.timer.invalidate()
        if(!self.isConnectedToNetwork()) {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkInternet:", userInfo: nil, repeats: false)
        } else {
            self.uploadAllPhotos()
        }
    }
    
    func putPhotoLinkToFirebase(link: String, teamNumber: Int, selectedImage: Bool) {
        let teamFirebase = self.teamsFirebase.childByAppendingPath("\(teamNumber)")
        let currentURLs = teamFirebase?.childByAppendingPath("otherImageUrls")
        currentURLs!.childByAutoId().setValue(link)
        if(selectedImage) {
            teamFirebase?.childByAppendingPath("selectedImageUrl").setValue(link)
        }
    }
    
    
}