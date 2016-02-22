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
    var teamNumbers : [Int]
    var mayKeepWorking = true {
        didSet {
            print("mayKeepWorking: \(mayKeepWorking)")
        }
    }
    
    var timer : NSTimer = NSTimer()
    var teamsFirebase : Firebase
    var numberOfPhotosForTeam = [Int: Int]()
    var callbackForPhotoCasheUpdated = { () in }
    var currentlyNotifyingTeamNumber = 0
    let dropboxClient : DropboxClient
    
    init(teamsFirebase : Firebase, teamNumbers : [Int]) {
        
        self.teamNumbers = teamNumbers
        self.teamsFirebase = teamsFirebase
        for number in teamNumbers {
            self.numberOfPhotosForTeam[number] = 0
        }
        self.dropboxClient = Dropbox.authorizedClient!
        super.init()
        self.sync()
    }
    
    
    
    func updatePhotoCache(fileObject: [String: AnyObject], teamNum: Int) {
        self.getPhotosForTeamNum(teamNum) { datas in
            var dicts = datas
            dicts.append(fileObject)
            self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(dicts), key: "photos\(teamNum)")
            if teamNum == self.currentlyNotifyingTeamNumber {
                self.callbackForPhotoCasheUpdated()
            }
        }
    }
    
    
    
    func getSharedURLsForTeam(num: Int, fetched: (NSMutableArray?)->()) {
        if self.mayKeepWorking {
            self.cache.fetch(key: "sharedURLs\(num)").onSuccess { (data) -> () in
                if let urls = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSMutableArray {
                    fetched(urls)
                } else {
                    fetched(nil)
                }
                }.onFailure { (E) -> () in
                    print("Failed to fetch URLS for team \(num)")
            }
        }
    }
    
    func fetchPhotosFromDropbox(var index: Int) {
        index++
        if index < self.teamNumbers.count {
            self.downloadPhotosForTeamNum(self.teamNumbers[index], success: { (datas) -> () in
                self.fetchPhotosFromDropbox(index)
                }, index: index)
        }
    }
    
    func downloadPhotosForTeamNum(number: Int, success: ([NSData])->(), index: Int) {
        if self.mayKeepWorking {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                if self.isConnectedToNetwork() {
                    self.dropboxClient.files.search(path: "/Public", query: "\(number)_").response({ (response, error) -> Void in
                        if let result = response {
                            var datas = [NSData]()
                            for match in result.matches {
                                self.downloadPhoto(match, teamNumber: number, success: { (data) in
                                    datas.append(data)
                                })
                            }
                            success(datas)
                        } else {
                            print("Query Error for team \(number), Error: \(error?.description)")
                        }
                    })
                }
            })
        }
        
    }
    
    func getPhotosForTeamNum(number: Int, success: ([[String: AnyObject]])->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            if self.mayKeepWorking {
                self.cache.fetch(key: "photos\(number)").onSuccess { (data) -> () in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        if let images = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String: AnyObject]] {
                            success(images)
                        }
                    })
                    }.onFailure { (E) -> () in
                        self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject([[String: AnyObject]]()), key: "photos\(number)")
                        self.cache.fetch(key: "photos\(number)").onSuccess { (data) -> () in
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                                if let images = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String: AnyObject]] {
                                    success(images)
                                }
                            })
                            }.onFailure { (E) -> () in
                                print("Failed to fetch photos for team \(number)")
                        }
                }
            }
        })
    }
    
    
    
    func downloadPhoto(searchMatch: Files.SearchMatch, teamNumber: Int, success: (NSData)->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            if(self.mayKeepWorking) {
                let name = searchMatch.metadata.name
                let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
                    let fileManager = NSFileManager.defaultManager()
                    let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                    // generate a unique name for this file in case we've seen it before
                    let UUID = NSUUID().UUIDString
                    let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
                    return directoryURL.URLByAppendingPathComponent(pathComponent)
                }
                
                self.dropboxClient.files.download(path: "/Public/\(name)", destination: destination).response { (response, error) in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        
                        if let (metadata, url) = response {
                            
                            //print("*** Download file ***")
                            var data = NSData(contentsOfURL: url)!
                            self.addFileToLineup(data, fileName: name, teamNumber: teamNumber, shouldUpload: false)
                            data = NSData()
                            //print("Downloaded file url: \(url)")
                            print("Downloaded file name: \(metadata.name)")
                            success(data)
                        } else {
                            print("Download error for name \(name), error: \(error!)")
                            self.downloadPhoto(searchMatch, teamNumber: teamNumber, success: success)
                        }
                    })
                }
            }
        })
    }
    
    func uploadPhoto(fileForTeam: [String: AnyObject], teamNumber: Int, index: Int, success: ()->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            if(self.mayKeepWorking) {
                let name = fileForTeam["name"] as! String
                var data = fileForTeam["data"] as! NSData
                var sharedURL = "Not Uploaded"
                let path = "/Public/\(name)"
                self.dropboxClient.files.upload(path: path, body: data).response { response, error in
                    if let metaData = response {
                        data = NSData()
                        //Removing the uploaded file from files to upload, this actually works in swift!
                        print("*** Upload file: \(metaData) ****")
                        sharedURL = "https://dl.dropboxusercontent.com/u/63662632/\(name)"
                        self.putPhotoLinkToFirebase(sharedURL, teamNumber: teamNumber, selectedImage: false)
                        self.addUrlToList(teamNumber, url: sharedURL)
                        success()
                    } else {
                        data = NSData()
                        self.dropboxClient.files.delete(path: path)
                        print("Upload Error: \(error?.description)")
                        self.uploadPhoto(fileForTeam, teamNumber: teamNumber, index: index, success: success)
                    }
                }
            }
        })
    }
    
    func getResizedImageDataForImageData(data: NSData) -> NSData {
        var image = UIImage(data: data)
        let newSize: CGSize = CGSize(width: (image?.size.width)! / 2, height: (image?.size.height)! / 2)
        let rect = CGRectMake(0,0, newSize.width, newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        // image is a variable of type UIImage
        image?.drawInRect(rect)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImagePNGRepresentation(image!)!
    }
    
    func fetchPhotosAndUploadForTeam(var i: Int, successOrFail: ()->()) {
        if self.teamNumbers.count > i {
            let teamNumber = self.teamNumbers[i]
            i++
            self.cache.fetch(key: "photos\(teamNumber)").onSuccess { (data) -> () in
                print("Fetched Photos for \(teamNumber)")
                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let images = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [[String: AnyObject]]
                print("Team \(teamNumber) has \(images.count) images.")
                if images.count == 0 {
                    self.fetchPhotosAndUploadForTeam(i, successOrFail: successOrFail)
                } else {
                    for index in 0...images.count - 1 {
                        var image = images[index]
                        if(image["-2"] == nil) {
                            //if image["shouldUpload"] as! Bool == true { //TESTING ONLY
                                self.uploadPhoto(image, teamNumber: teamNumber, index:index, success: successOrFail)
                            //}
                        }
                        image = [String:AnyObject]()
                    }
                }
                //})
                }.onFailure { (E) -> () in
                    print("Failed to fetch photo for \(teamNumber)")
                    self.fetchPhotosAndUploadForTeam(i, successOrFail: successOrFail)
            }
        }
        
    }
    
    func uploadAllPhotos(var currentIndex: Int) {
        if(self.isConnectedToNetwork()) {
            
            if currentIndex < self.teamNumbers.count {
                fetchPhotosAndUploadForTeam(self.teamNumbers[currentIndex], successOrFail: { () -> () in
                    currentIndex++
                    self.uploadAllPhotos(currentIndex)
                })
            }
            
        } else {
            
        }
    }
    
    func addUrlToList(teamNumber: Int, url: String) {
        self.getSharedURLsForTeam(teamNumber) { (urls) -> () in
            if let nurls = urls {
                nurls.addObject(url)
                self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(nurls), key: "sharedURLs\(teamNumber)")
            }
        }
    }
    
    
    func addFileToLineup(var fileData : NSData, fileName : String, teamNumber : Int, shouldUpload : Bool) {
        if (Double(fileData.length) / pow(2.0, 20.0)) > 10 {
            fileData = self.getResizedImageDataForImageData(fileData)
        }
        let fileDict : [String: AnyObject] = ["name" : fileName, "data" : fileData, "shouldUpload": shouldUpload]
        self.updatePhotoCache(fileDict, teamNum: teamNumber)
        self.numberOfPhotosForTeam[teamNumber]!++
        if shouldUpload {
            self.uploadPhoto(fileDict, teamNumber: teamNumber, index: self.numberOfPhotosForTeam[teamNumber]!, success: { () in })
        }
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            self.timer.invalidate()
            if(!self.isConnectedToNetwork()) {
                NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "checkInternet:", userInfo: nil, repeats: false)
            } else {
                //NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "uploadAllPhotos:", userInfo: nil, repeats: false)
            }
        })
    }
    
    func putPhotoLinkToFirebase(link: String, teamNumber: Int, selectedImage: Bool) {
        
        let teamFirebase = self.teamsFirebase.childByAppendingPath("\(teamNumber)")
        let currentURLs = teamFirebase?.childByAppendingPath("otherImageUrls")
        currentURLs!.childByAutoId().setValue(link)
        if(selectedImage) {
            teamFirebase?.childByAppendingPath("selectedImageUrl").setValue(link)
        }
        
    }
    
    func sync() {
        self.mayKeepWorking = true
        self.fetchPhotosFromDropbox(0)
        self.uploadAllPhotos(0)
    }
    
    
}