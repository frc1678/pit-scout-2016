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
    var mayKeepUsingNetwork = true {
        didSet {
            print("mayKeepUsingNetwork: \(mayKeepUsingNetwork)")
        }
    }
    
    var thumbs : [Int : [[String: AnyObject]]] = [Int : [[String: AnyObject]]]()
    //var photosToUpload : [Int : [[String: AnyObject]]] = [Int : [[String: AnyObject]]]()
    var sharedURLs : [Int : NSMutableArray] = [Int : NSMutableArray]() {
        didSet {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(self.sharedURLs), key: "sharedURLs")
            })
        }
    }
    var timer : NSTimer = NSTimer()
    var teamsFirebase : Firebase
    
    init(teamsFirebase : Firebase, teamNumbers : [Int]) {
        
        self.teamNumbers = teamNumbers
        self.teamsFirebase = teamsFirebase
        for number in teamNumbers {
            //self.photosToUpload[number] = []
            self.thumbs[number] = [[String: AnyObject]]()
            self.sharedURLs[number] = []
        }
        
        super.init()
        self.fetchToUpdate()
    }
    
    func updatePhotoCache(fileObject: [String: AnyObject], teamNum: Int) {
        self.cache.fetch(key: "photos\(teamNum)").onSuccess { (data) -> () in
            var images = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String: AnyObject]]
            if images == nil {
                images = [[String: AnyObject]]()
            }
            images?.append(fileObject)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(images!), key: "photos\(teamNum)")
            })
            }.onFailure { (E) -> () in
                print("failed to fetch images from cache \(E)")
        }
    }
    
    func fetchPhotos(failCallback: (failedNums: [Int]) -> (), additionalSuccessCallback: () -> ()) {
        var fails = [Int]()
        for teamNum in self.teamNumbers {
            self.cache.fetch(key: "photos\(teamNum)").onSuccess { (data) -> () in
                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    let images = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String: AnyObject]]
                    if let imagesForTeam = images {
                        if !(imagesForTeam[0]["-2"] as! Int == -2 && imagesForTeam.count == 1) {
                            self.thumbs[teamNum] = imagesForTeam
                            for fileIndex in imagesForTeam.indices {
                                if fileIndex > 0 {
                                    self.thumbs[teamNum]![fileIndex]["image"] = UIImage(data: self.getResizedImageDataForImageData(self.thumbs[teamNum]![fileIndex]["data"] as! NSData))
                                    self.thumbs[teamNum]![fileIndex]["data"] = nil
                                }
                            }
                        }
                    }
               // })
                }.onFailure({ (E) -> () in
                    fails.append(teamNum)
                })
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            if fails.count > 0 {
                failCallback(failedNums: fails)
            } else {
                additionalSuccessCallback()
            }
        })
    }
    
    
    
    
    func fetchSharedURLs(failCallback: (NSError?) -> (), additionalSuccessCallback: (NSData) -> ()) {
        
        self.cache.fetch(key: "sharedURLs").onSuccess { (data) -> () in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                let urls = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Int: NSMutableArray]
                var su = [Int : NSMutableArray]()
                for teamNum in self.teamNumbers {
                    if let urlsForTeam = urls[teamNum] {
                        if su[teamNum] != nil {
                            if urlsForTeam != su[teamNum]! {
                                su[teamNum] = urlsForTeam
                            }
                        } else {
                            su[teamNum] = urlsForTeam
                        }
                    }
                }
                self.sharedURLs = su
                additionalSuccessCallback(data)
            })
            }.onFailure { (E) -> () in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    failCallback(E)
                })
        }
        
    }
    
    
    func fetchToUpdate() {
        self.fetchPhotos({ (fails) -> () in
            for num in fails {
                self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject([["-2":-2]]), key: "photos\(num)")
            }
            }, additionalSuccessCallback: { (data) -> () in //We succeded in fetching photos
                print("Photos Fetched")
                self.fetchSharedURLs({ (E) -> () in //We failed to fetch URLs
                    print("URLs Not Fetched \(E.debugDescription)")
                    self.sharedURLs = [-2:["-2"]]
                    self.fetchSharedURLs({ (E) -> () in }, additionalSuccessCallback: { (data) -> () in //After failing to fetch URLs, we succeeded in fetching URLs
                        print("URLs Fetched")
                        self.uploadAllPhotos()
                    })
                    }, additionalSuccessCallback: { (data) -> () in //We succeeded in fetching URLs
                        print("URLs Fetched")
                        
                        self.uploadAllPhotos()
                        
                })
        })
        
    }
    
    func fetchPhotosFromDropbox() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            if self.isConnectedToNetwork() {
                if let client = Dropbox.authorizedClient {
                    for teamNumber in self.teamNumbers {
                        client.files.search(path: "/Public", query: "\(teamNumber)_").response({ (response, error) -> Void in
                            if let result = response {
                                for match in result.matches {
                                    self.downloadPhoto(client, searchMatch: match, teamNumber: teamNumber)
                                }
                            } else {
                                print("Query Error for team \(teamNumber), Error: \(error?.description)")
                            }
                        })
                    }
                }
            }
        })
    }
    
    func getSharedURLsForTeamNum(number: Int) -> NSMutableArray {
        return self.sharedURLs[number]!
    }
    
    
    func getThumbsForTeamNum(number: Int) -> [[String: AnyObject]] {
        return self.thumbs[number]!
    }
    
    func downloadPhoto(client: DropboxClient, searchMatch: Files.SearchMatch, teamNumber: Int) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
        
        if(self.mayKeepUsingNetwork) {
            let name = searchMatch.metadata.name
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
                    let data = NSData(contentsOfURL: url)!
                    let thumbData = self.getResizedImageDataForImageData(data)
                    self.addThumb(UIImage(data: thumbData)!, fileName: name, teamNumber: teamNumber, shouldUpload: false)
                    self.addFileToLineup(data, fileName: name, teamNumber: teamNumber, shouldUpload: false)
                    print("Downloaded file url: \(url)")
                    print("Downloaded file name: \(metadata.name)")
                } else {
                    print("Download error for name \(name), error: \(error!)")
                    self.downloadPhoto(client, searchMatch: searchMatch, teamNumber: teamNumber)
                }
            }
        }
        //})
    }
    
    func uploadPhoto(filesForTeam: [[String: AnyObject]], client: DropboxClient, teamNumber: Int, index: Int) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
        
        if(self.mayKeepUsingNetwork) {
            let name = filesForTeam[index]["name"] as! String
            let data = filesForTeam[index]["data"] as! NSData
            var sharedURL = "Not Uploaded"
            let path = "/Public/\(name)"
            client.files.upload(path: path, body: data).response { response, error in
                if let metaData = response {
                    self.thumbs[teamNumber]![index]["shouldUpload"] = false
                    
                    //Removing the uploaded file from files to upload, this actually works in swift!
                    print("*** Upload file: \(metaData) ****")
                    sharedURL = "https://dl.dropboxusercontent.com/u/63662632/\(name)"
                    self.putPhotoLinkToFirebase(sharedURL, teamNumber: teamNumber, selectedImage: false)
                    self.addUrlToList(teamNumber, url: sharedURL)
                    //print(self.sharedURLs)
                } else {
                    client.files.delete(path: path)
                    print("Upload Error: \(error?.description)")
                    //sleep(4)
                    self.uploadPhoto(filesForTeam, client: client, teamNumber: teamNumber, index: index)
                }
            }
        }
        //})
    }
    
    
    func uploadAllPhotos() {
        if(self.isConnectedToNetwork()) {
            if let client = Dropbox.authorizedClient {
                for teamNumber in self.teamNumbers {
                    self.cache.fetch(key: "photos\(teamNumber)").onSuccess { (data) -> () in
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                            let images = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [[String: AnyObject]]
                            for index in images.indices {
                                let image = images[index]
                                if image["shouldUpload"] as! Bool == true {
                                    self.uploadPhoto([image], client: client, teamNumber: teamNumber, index: index)
                                }
                            }
                            
                        })
                    }
                }
                
                
            } else {
                self.checkInternet(self.timer)
            }
        }
        
    }
    
    
    func addUrlToList(teamNumber: Int, url: String) {
        self.sharedURLs[teamNumber]![(self.sharedURLs[teamNumber]?.count)!] = url //This line is terrible
    }
    
    func getResizedImageDataForImageData(data: NSData) -> NSData {
        let imageOrigional = UIImage(data: data)
        let newSize: CGSize = CGSize(width: (imageOrigional?.size.width)! / 8, height: (imageOrigional?.size.height)! / 8)
        let rect = CGRectMake(0,0, newSize.width, newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        // image is a variable of type UIImage
        imageOrigional?.drawInRect(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImagePNGRepresentation(newImage)!
        
    }
    
    func addThumb(image : UIImage, fileName : String, teamNumber : Int, shouldUpload: Bool) {
        let fileDict : [String: AnyObject] = ["name" : fileName, "image" : image, "shouldUpload": shouldUpload]
        self.thumbs[teamNumber]?.append(fileDict)
    }
    
    func addFileToLineup(fileData : NSData, fileName : String, teamNumber : Int, shouldUpload : Bool) {
        let fileDict : [String: AnyObject] = ["name" : fileName, "data" : fileData, "shouldUpload": shouldUpload]
        self.updatePhotoCache(fileDict, teamNum: teamNumber)
        
        if shouldUpload {
            if let client = Dropbox.authorizedClient {
                self.uploadPhoto([fileDict], client: client, teamNumber: teamNumber, index: 0)
            }
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
        self.timer.invalidate()
        if(!self.isConnectedToNetwork()) {
            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "checkInternet:", userInfo: nil, repeats: false)
        } else {
            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "uploadAllPhotos:", userInfo: nil, repeats: false)
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